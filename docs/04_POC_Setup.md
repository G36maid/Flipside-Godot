# 04. POC Setup Guide

## Purpose
This document describes the initial Proof-of-Concept (POC) structure created for **Phase 1: Physics Prototype**.

The goal is to validate the core "Dumbbell" vehicle architecture and adhesion mechanics before moving into full production.

---

## Directory Structure

```
.
├── assets/                          # Raw assets (currently placeholder)
│   ├── sprites/
│   └── .gdignore                    # Prevents Godot from importing source files
├── docs/
│   ├── 01_Game_design.md
│   ├── 02_Architecture.md
│   ├── 03_Roadmap.md
│   └── 04_POC_Setup.md              # This file
├── src/                             # Core game source code
│   ├── _core/
│   │   ├── global_constants.gd      # Physics parameters & tunable constants
│   │   └── .gitkeep
│   ├── components/
│   │   ├── adhesion_detector/       # Future: Reusable ground detection component
│   │   └── .gitkeep
│   ├── entities/
│   │   ├── vehicle/
│   │   │   ├── vehicle.tscn         # Main vehicle scene (3 RigidBody + 2 PinJoint)
│   │   │   └── vehicle_controller.gd # Adhesion logic & input handling
│   │   └── .gitkeep
│   ├── levels/
│   │   ├── test/
│   │   │   └── poc_physics.tscn     # ⭐ Main POC scene for testing
│   │   └── .gitkeep
│   └── ui/
│       ├── debug/                   # Future: Physics debugger HUD
│       └── .gitkeep
├── tools/                           # Future: EditorScripts (Path2D → Polygon)
│   └── .gitkeep
├── .gitignore
├── project.godot                    # Updated with autoloads & main scene
└── README.md
```

---

## Key Files

### 1. `src/_core/global_constants.gd`
**Purpose**: Centralized physics tuning parameters.

**Key Constants**:
- `ADHESION_VELOCITY_THRESHOLD = 300.0` - Minimum speed to maintain wall grip
- `ADHESION_FORCE_MULTIPLIER = 2000.0` - Downforce strength
- `WHEEL_MOTOR_TORQUE = 5000.0` - Ground propulsion force
- `AIR_TORQUE = 8000.0` - Airborne rotation control

**Autoload**: Registered as `GlobalConstants` singleton in `project.godot`.

---

### 2. `src/entities/vehicle/vehicle.tscn`
**Purpose**: The "Dumbbell" vehicle structure.

**Scene Tree**:
```
Vehicle (Node2D)
├── Chassis (RigidBody2D) - No collision, mass=1.0
├── WheelLeft (RigidBody2D) - CircleShape, mass=0.5
│   └── GroundDetector (RayCast2D)
├── WheelRight (RigidBody2D) - CircleShape, mass=0.5
│   └── GroundDetector (RayCast2D)
├── JointLeft (PinJoint2D) - Connects Chassis ↔ WheelLeft
└── JointRight (PinJoint2D) - Connects Chassis ↔ WheelRight
```

**Physics Setup**:
- Chassis has `collision_layer = 0` to prevent belly scraping
- Wheels have high friction (`PhysicsMaterial.friction = 1.0`)
- RayCasts detect ground and extract surface normals

---

### 3. `src/entities/vehicle/vehicle_controller.gd`
**Purpose**: Implements the core adhesion algorithm.

**Key Logic**:
```gdscript
func _apply_adhesion_logic() -> void:
    if is_adhered:
        # Disable global gravity
        gravity_scale = 0.0
        # Apply downforce toward surface
        apply_central_force(-surface_normal * ADHESION_FORCE_MULTIPLIER)
    else:
        # Re-enable global gravity (fall)
        gravity_scale = 1.0
```

**Input Handling** (TODO):
- Ground: Apply motor torque to PinJoints
- Air: Apply torque to chassis for rotation

---

### 4. `src/levels/test/poc_physics.tscn`
**Purpose**: Main testing scene for Phase 1.

**Contents**:
- Ground plane (flat surface)
- Ceiling plane (for wall-running test)
- Vehicle instance
- Camera2D (zoomed out)
- Debug label (velocity/adhesion state)

**How to Test**:
1. Open `poc_physics.tscn` in Godot
2. Press F5 to run
3. Use arrow keys to control (once input is implemented)
4. Observe adhesion behavior when velocity > threshold

---

## Phase 1 Validation Checklist

- [ ] **Vehicle falls naturally** when speed < `ADHESION_VELOCITY_THRESHOLD`
- [ ] **Vehicle sticks to ground** when speed > threshold
- [ ] **RayCasts detect surface normals** correctly
- [ ] **Downforce direction** aligns with surface normal
- [ ] **Wheels can drive on ceiling** (upside-down test)
- [ ] **360° loop traversal** without falling (future test)

---

## Next Steps (Phase 1 Continuation)

1. **Implement Input Handling**:
   - Ground mode: Motor force on PinJoints
   - Air mode: Torque on chassis

2. **Create Test Track**:
   - Add curved surfaces (Path2D → Polygon conversion)
   - Test on 90° wall and 360° loop

3. **Debug Visualization**:
   - Draw velocity vectors
   - Draw surface normals
   - Display real-time physics state in HUD

4. **Tune Constants**:
   - Adjust `ADHESION_VELOCITY_THRESHOLD` for feel
   - Balance motor torque vs. adhesion force

---

## Opening the Project

1. **Prerequisites**: Godot 4.5+ (Standard version)
2. **Import**: Open Godot → Import → Select `project.godot`
3. **Run POC**: Open `src/levels/test/poc_physics.tscn` → Press F5

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Vehicle falls through floor | Check collision layers/masks on wheels |
| Vehicle doesn't stick to ceiling | Increase `ADHESION_FORCE_MULTIPLIER` in `global_constants.gd` |
| RayCast not detecting | Verify `target_position` points downward from wheel |
| Autoload not found | Re-import project (Project → Reload Current Project) |

---

## References

- [01_Game_design.md](01_Game_design.md) - Core mechanics rules
- [02_Architecture.md](02_Architecture.md) - Detailed physics implementation
- [03_Roadmap.md](03_Roadmap.md) - Development phases

---

**Last Updated**: 2026-01-20  
**Phase**: POC (Phase 1 - In Progress)
