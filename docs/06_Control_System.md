# Control System Documentation

**Phase**: POC (Proof of Concept)  
**Last Updated**: 2026-01-20  
**Status**: Implemented and Tuned

---

## Overview

The Flipside vehicle uses a **mode-dependent control system** that automatically switches between ground and air control based on the vehicle's adhesion state.

---

## Control Modes

### Ground Mode (GROUND State)
**Active When**: 
- Velocity > 300 px/s (ADHESION_VELOCITY_THRESHOLD)
- At least one wheel's RayCast detects ground within 64px

**Input Behavior**:
```gdscript
var wheel_torque = input_direction * WHEEL_MOTOR_TORQUE
wheel_left.apply_torque(wheel_torque)
wheel_right.apply_torque(wheel_torque)
```

**Physics**:
- Applies torque directly to both wheel RigidBody2D nodes
- Wheels rotate via friction against ground
- Torque value: **5000.0** (responsive acceleration)

### Air Mode (AIR State)
**Active When**:
- Velocity < 250 px/s (THRESHOLD - HYSTERESIS), OR
- No RayCast detection (wheels off ground)

**Input Behavior**:
```gdscript
var air_torque = input_direction * AIR_TORQUE
chassis.apply_torque(air_torque)
```

**Physics**:
- Applies torque to chassis RigidBody2D for rotation
- Allows mid-air orientation adjustment for landing
- Torque value: **800.0** (controllable ~1.3s per rotation)
- Chassis inertia: **166.67 kg·px²** (calculated from 40x20 rectangle)

---

## Input Mapping

| Action | Key Binding | Effect |
|--------|-------------|--------|
| Accelerate Right | Right Arrow (`ui_right`) | Positive torque |
| Accelerate Left / Brake | Left Arrow (`ui_left`) | Negative torque |

**Input Reading**:
```gdscript
var input_dir: float = Input.get_axis("ui_left", "ui_right")
# Returns: -1.0 (left), 0.0 (neutral), +1.0 (right)
```

---

## Parameters

### Tuned Values (GlobalConstants.gd)

| Parameter | Value | Purpose | Notes |
|-----------|-------|---------|-------|
| `WHEEL_MOTOR_TORQUE` | 5000.0 | Ground acceleration force | Balanced for responsive feel |
| `AIR_TORQUE` | 800.0 | Air rotation torque | ~4.8 rad/s² angular acceleration |
| `ADHESION_VELOCITY_THRESHOLD` | 300.0 | Speed needed to stick | Minimum for wall-running |
| `ADHESION_HYSTERESIS` | 50.0 | State transition buffer | Prevents flickering (250-350 range) |
| `CHASSIS_MASS` | 1.0 | Chassis weight | Affects overall vehicle dynamics |
| `WHEEL_MASS` | 0.5 | Each wheel weight | Lower mass = more responsive |

### Calculated Properties

**Chassis Inertia** (set in `vehicle_controller.gd`):
```gdscript
var chassis_width: float = 40.0
var chassis_height: float = 20.0
chassis.inertia = CHASSIS_MASS * (chassis_width² + chassis_height²) / 12.0
# Result: 166.67 kg·px²
```

**Why Manual Inertia?**  
Chassis has no CollisionShape2D (prevents belly scraping), so Godot can't auto-calculate inertia. Without manual setting, `apply_torque()` would have no effect (inertia = 0).

---

## Implementation Details

### Architecture

1. **Input Detection** (`_handle_input()`):
   - Called every `_physics_process()` frame
   - Reads `Input.get_axis()` for direction
   - Checks `control_state` enum

2. **Mode Switching** (`_update_physics_state()`):
   - Updates `control_state` based on:
     - Current velocity
     - RayCast ground detection
     - Hysteresis buffer
   - Runs before input handling each frame

3. **Force Application**:
   - Ground: `RigidBody2D.apply_torque()` on wheels
   - Air: `RigidBody2D.apply_torque()` on chassis
   - Frame-rate independent (uses Godot's physics timestep)

### Key Design Decisions

#### ✅ Direct Wheel Torque (Not PinJoint Motor)
**Why**: PinJoint2D `motor_target_velocity` is:
- Poorly documented in Godot
- Rarely used in real projects
- Difficult to tune for responsive feel

**Alternative**: Direct `apply_torque()` gives:
- Simple, predictable behavior
- Easy to debug and tune
- Standard Godot physics pattern

#### ✅ Automatic Mode Switching
**Why**: Player shouldn't manually switch modes mid-game.

**Implementation**: Adhesion state machine handles it:
```
GROUND → AIR: when velocity < 250 OR wheels lose contact
AIR → GROUND: when velocity > 350 AND wheels detect ground
```

#### ✅ Torque (Not Velocity/Force)
**Why**: 
- Torque feels natural for wheels (spinning)
- Physics engine handles friction automatically
- No need to manually calculate tangential forces

---

## Testing & Tuning

### Test Scene: `poc_physics.tscn`

**Features**:
- Flat ground for acceleration testing
- 30° ramp at (400, 300) for jump testing
- Debug visualization (velocity vectors, ray detection)

**Testing Checklist**:

1. **Ground Acceleration**:
   - [ ] Vehicle accelerates smoothly from standstill
   - [ ] Reaches ~300 px/s in reasonable time (~2-3 seconds)
   - [ ] Can decelerate with opposite input

2. **Air Control**:
   - [ ] Vehicle rotates when airborne
   - [ ] Rotation speed is controllable (not too fast)
   - [ ] Can adjust orientation before landing

3. **Mode Transitions**:
   - [ ] Smooth switch from GROUND → AIR (no stuttering)
   - [ ] Smooth switch from AIR → GROUND (no flickering)
   - [ ] Debug overlay shows correct state changes

### Tuning Guide

**If ground acceleration is too slow**:
```gdscript
# Increase from 5000.0 to 7000.0 or higher
const WHEEL_MOTOR_TORQUE: float = 7000.0
```

**If ground acceleration is too fast**:
```gdscript
# Decrease from 5000.0 to 3000.0 or lower
const WHEEL_MOTOR_TORQUE: float = 3000.0
```

**If air rotation is too slow**:
```gdscript
# Increase from 800.0 to 1200.0
const AIR_TORQUE: float = 1200.0
```

**If air rotation is too fast** (spinning out of control):
```gdscript
# Decrease from 800.0 to 500.0
const AIR_TORQUE: float = 500.0
```

**If mode switching is flickering**:
```gdscript
# Increase hysteresis from 50.0 to 100.0
const ADHESION_HYSTERESIS: float = 100.0
```

---

## Known Limitations (POC Phase)

1. **Single Player Only**: Input uses global `Input.get_axis()`, not multiplayer-ready
2. **No Brake Mechanic**: Left input applies reverse torque (not realistic braking)
3. **No Speed Limit**: Vehicle can accelerate indefinitely (friction is only resistance)
4. **Binary Input**: No gamepad analog support (keyboard is on/off)

These will be addressed in **Phase 2: Production Implementation**.

---

## Future Enhancements (Phase 2+)

### Multiplayer Input
```gdscript
# Per-player input handling
var player_id: int = 1
var input_dir: float = Input.get_axis("p%d_left" % player_id, "p%d_right" % player_id)
```

### Analog Input Support
```gdscript
# Gamepad analog stick
var analog_input: float = Input.get_joy_axis(joy_id, JOY_AXIS_LEFT_X)
var wheel_torque = analog_input * WHEEL_MOTOR_TORQUE  # Smooth 0-100% control
```

### Advanced Features
- Boost mechanic (temporary torque multiplier)
- Drift mechanic (differential wheel torque)
- Wall-jump (impulse when transitioning surfaces)
- Speed-dependent steering (tighter control at high speeds)

---

## Code References

### Primary Files
- `src/entities/vehicle/vehicle_controller.gd` - Main control logic
- `src/_core/global_constants.gd` - Tunable parameters
- `src/levels/test/poc_physics.tscn` - Test environment

### Key Functions
```gdscript
func _handle_input(delta: float) -> void
    # Processes player input and applies torque

func _update_physics_state() -> void
    # Updates control_state enum (GROUND/AIR)

func _apply_adhesion_forces() -> void
    # Handles custom gravity when adhered
```

---

## Changelog

### 2026-01-20: Initial Implementation
- Implemented direct wheel torque control
- Added chassis inertia calculation
- Tuned AIR_TORQUE from 8000 → 800 (10x reduction)
- Added test ramp to POC scene
- Removed initial velocity (player controls from standstill)

---

**Next Steps**: Test in Godot editor and gather player feedback for final tuning.
