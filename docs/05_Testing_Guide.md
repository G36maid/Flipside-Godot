# POC Physics Testing Guide

## Quick Start

### Running the Test Scene

```bash
# Open in Godot Editor
godot --editor .

# Or run directly
godot res://src/levels/test/poc_physics.tscn
```

Press **F5** in the editor to launch the test scene.

---

## Current Test Setup (Phase 1 - Initial Adhesion Test)

### What's Implemented

✅ **Vehicle Structure**:
- Dumbbell model (chassis + 2 wheels + 2 pin joints)
- Collision shapes on wheels (CircleShape2D, radius=16px)
- RayCast2D ground detectors on each wheel
- PhysicsMaterial with friction=1.0, bounce=0.0

✅ **Adhesion Mechanics**:
- Velocity-threshold based adhesion (300 px/s)
- Hysteresis buffer (±50 px/s) to prevent flickering
- Surface normal extraction from RayCast collisions
- Custom gravity cancellation via force application

✅ **Debug Visualization**:
- Yellow vector: Current velocity direction
- Cyan vector: Surface normal (when adhered)
- Text overlay: Real-time state (velocity, adhesion, control mode)

✅ **Test Environment**:
- Ground plane (bottom)
- Ceiling plane (top, red) - for wall-running test
- Left/right walls (blue) - for containment
- Camera follows vehicle automatically

### Initial Test Conditions

The vehicle spawns with:
- Position: (-600, 350) - left side, near ground
- **Initial velocity: 400 px/s rightward** (to trigger adhesion)

---

## Expected Behavior

### Phase 1: Ground Adhesion Test

1. **Spawn** (t=0s):
   - Vehicle starts with 400 px/s horizontal velocity
   - Should immediately show "Adhered: YES" (velocity > 300)
   - Yellow velocity vector points right
   - Cyan normal vector points up

2. **Ground Contact** (t=0.1s):
   - Wheels touch ground
   - RayCasts detect surface normal
   - Adhesion forces activate
   - Vehicle should stick to ground despite moving fast

3. **Deceleration** (t=1-3s):
   - Friction causes velocity to drop
   - Watch for hysteresis:
     - "Adhered: YES" until velocity < 250 px/s
     - "Adhered: NO" when falling below threshold
   - Once below threshold, global gravity pulls vehicle down

4. **Settling** (t=3-5s):
   - Vehicle comes to rest on ground
   - State shows "AIR" mode (no adhesion)
   - Debug vectors may disappear (zero velocity)

---

## What to Verify

### ✅ Success Criteria

| Test | Pass Condition | Debug Visual |
|------|----------------|--------------|
| **Initial Adhesion** | "Adhered: YES" at spawn | Cyan vector appears |
| **Ground Stick** | Vehicle doesn't fall while fast | Yellow vector stable |
| **Hysteresis** | No rapid flickering between states | Smooth state transitions |
| **Deceleration** | Velocity decreases over time | Yellow vector shrinks |
| **Detachment** | "Adhered: NO" below ~250 px/s | Cyan vector disappears |
| **Gravity Fallback** | Vehicle settles on ground naturally | Comes to rest |

### ⚠️ Known Limitations

| Issue | Why It Happens | Workaround |
|-------|----------------|------------|
| **No continuous motion** | Motor control not yet implemented | Vehicle stops after initial momentum |
| **Can't control vehicle** | Input handling TODO | Currently spectator mode only |
| **Doesn't climb walls** | Insufficient initial velocity | Test ceiling adhesion in Phase 2 |
| **No rotation control** | Air torque not implemented | Will add in Phase 2 |

---

## Debugging Common Issues

### Vehicle Falls Through Ground

**Symptom**: Vehicle passes through floor

**Causes**:
1. Collision layers misconfigured
   - Check: `wheel_left.collision_mask = 1`
   - Check: `Ground.collision_layer = 1`
2. Physics simulation too fast for thin collision
   - Fix: Increase wheel CollisionShape2D radius

**Solution**:
```gdscript
# In vehicle_controller.gd _ready()
print("Wheel collision mask: ", wheel_left.collision_mask)
print("Ground collision layer: ", $Ground.collision_layer)
```

---

### Adhesion Never Activates

**Symptom**: "Adhered: NO" always shows, even at high speed

**Causes**:
1. RayCast not detecting ground
   - Check: `ray_left.is_colliding()` returns true
2. Initial velocity not applied
   - Check: Yellow velocity vector appears at spawn

**Solution**:
```gdscript
# Add to _update_physics_state()
print("Left grounded: ", ray_left.is_colliding())
print("Current velocity: ", current_velocity)
```

---

### Vehicle Bounces/Jitters

**Symptom**: Vehicle vibrates on ground

**Causes**:
1. Collision shape overlapping ground at spawn
   - Fix: Spawn slightly higher (y=300 → y=280)
2. PhysicsMaterial bounce > 0
   - Check: `wheel_material.bounce == 0.0`
3. PinJoint softness causing oscillation
   - Check: `joint_left.softness == 0.0`

**Solution**: Increase damping in GlobalConstants:
```gdscript
# Add to global_constants.gd
const LINEAR_DAMP: float = 0.5
const ANGULAR_DAMP: float = 0.5

# Apply in vehicle_controller.gd _ready()
wheel_left.linear_damp = GlobalConstants.LINEAR_DAMP
wheel_right.linear_damp = GlobalConstants.LINEAR_DAMP
chassis.angular_damp = GlobalConstants.ANGULAR_DAMP
```

---

### Hysteresis Flickering

**Symptom**: "Adhered" state toggles rapidly

**Causes**:
1. Hysteresis buffer too small (50 px/s insufficient)
2. Velocity calculation unstable

**Solution**: Increase hysteresis in global_constants.gd:
```gdscript
const ADHESION_HYSTERESIS: float = 100.0  # Was 50.0
```

---

## Manual Testing Checklist

Before moving to Phase 2, verify:

- [ ] Vehicle spawns with initial velocity
- [ ] Debug overlay shows state correctly
- [ ] Yellow velocity vector visible and accurate
- [ ] "Adhered: YES" triggers at spawn (v=400 > 300)
- [ ] Cyan normal vector appears when adhered
- [ ] RayCasts detect ground (check console if needed)
- [ ] Adhesion forces prevent falling at high speed
- [ ] Velocity decreases gradually due to friction
- [ ] Hysteresis prevents rapid state toggling
- [ ] "Adhered: NO" triggers below ~250 px/s
- [ ] Vehicle settles naturally on ground
- [ ] No excessive bouncing or jittering
- [ ] Camera follows vehicle smoothly
- [ ] No errors in Output console

---

## Performance Profiling

### Expected Physics Metrics

| Metric | Target | Check With |
|--------|--------|------------|
| Physics FPS | 60 | Debug → Monitor → Physics FPS |
| Frame Time | <16ms | Profiler → Physics Process |
| Node Count | <20 | Remote → Scene Tree |
| Force Applications | 3/frame | Custom print in _apply_adhesion_forces() |

### Profiling Commands

```gdscript
# Add to vehicle_controller.gd for diagnostics
func _physics_process(delta: float) -> void:
    var start_time = Time.get_ticks_usec()
    
    _update_physics_state()
    _handle_input(delta)
    _apply_adhesion_forces()
    queue_redraw()
    
    var elapsed = Time.get_ticks_usec() - start_time
    if elapsed > 500:  # Warn if >0.5ms
        print("Physics process took: ", elapsed, " μs")
```

---

## Next Steps (Phase 2 Preparation)

Once Phase 1 tests pass, prepare for:

### Phase 2A: Motor Control
- [ ] Implement ground motor force (PinJoint2D)
- [ ] Test sustained motion and acceleration
- [ ] Verify friction-based propulsion works

### Phase 2B: Air Control
- [ ] Implement chassis torque for rotation
- [ ] Test mid-air orientation adjustment
- [ ] Verify torque doesn't interfere with ground mode

### Phase 2C: Wall Running
- [ ] Build vertical wall test section
- [ ] Increase initial velocity to 500-600 px/s
- [ ] Verify adhesion on 90° surfaces
- [ ] Test normal vector calculation on walls

### Phase 2D: Ceiling Test
- [ ] Launch vehicle toward ceiling at high speed
- [ ] Verify upside-down adhesion works
- [ ] Test transition from floor → ceiling

---

## Troubleshooting Contact Points

If tests fail consistently:

1. **Check Project Settings**:
   - Project → Project Settings → Physics → 2D
   - Default Gravity: 980
   - Default Linear Damp: 0.0
   - Physics Ticks per Second: 60

2. **Verify Autoload**:
   - Project → Project Settings → Autoload
   - GlobalConstants → res://src/_core/global_constants.gd
   - Enabled: Yes

3. **Scene Integrity**:
   - Open `vehicle.tscn` in editor
   - Verify all node paths resolve (no warnings)
   - Check PinJoint2D node_a/node_b connections

4. **Console Output**:
   - Look for red errors in Output tab
   - Check for null references
   - Verify RayCast collision mask matches layer

---

**Last Updated**: 2026-01-20  
**Test Scene**: `res://src/levels/test/poc_physics.tscn`  
**Phase**: 1 - Adhesion Mechanics Validation
