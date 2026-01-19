# AGENTS.md

**Agent Guidelines for Flipside-Godot Development**

This document provides essential context for AI coding agents working on the Flipside-Godot project—a Godot 4.5 recreation of Nitrome's Flash classic "Flipside" (2009).

---

## 📦 Project Overview

- **Engine**: Godot 4.5+ (Standard Version, GL Compatibility)
- **Language**: GDScript (strict typing enforced)
- **Architecture**: Feature-based + Component-based structure
- **Physics**: RigidBody2D simulation with custom adhesion mechanics
- **Phase**: Phase 1 (POC) - Physics Prototype validation

**Key Features Being Prototyped**:
- "Dumbbell" vehicle structure (RigidBody + PinJoints)
- Velocity-threshold adhesion system for wall-running
- Momentum-based physics on smooth collision polygons

---

## 🚀 Running & Testing

### Manual Testing (Primary Workflow)

```bash
# Open project in Godot Editor
godot --editor .

# Run the main test scene (F5 in editor)
godot res://src/levels/test/poc_physics.tscn
```

**Main Test Scene**: `res://src/levels/test/poc_physics.tscn`  
This is the POC physics sandbox. Use F5 in the editor to launch it.

### No Automated Testing (Yet)

- **No test framework installed** (GUT not yet integrated)
- **No CI/CD pipeline** configured
- **Testing strategy**: Manual scene execution and visual debugging

### Build & Export

Currently handled via Godot Editor's Export menu. No automated build scripts exist.

---

## 🛠️ Code Style Guidelines

### 1. File & Folder Naming

- **snake_case** for all files and folders: `vehicle_controller.gd`, `poc_physics.tscn`
- **Underscore prefix** for internal/core modules: `_core/`, `_helpers/`

### 2. GDScript Naming Conventions

```gdscript
# Constants: SCREAMING_SNAKE_CASE
const ADHESION_VELOCITY_THRESHOLD: float = 300.0

# Variables & Functions: snake_case
var is_adhered: bool = false
func _handle_input(delta: float) -> void:

# Private functions: underscore prefix
func _update_physics_state() -> void:

# Node references: descriptive snake_case
@onready var wheel_left: RigidBody2D = $WheelLeft
```

### 3. Type Safety (MANDATORY)

**All variables, constants, and function signatures MUST be explicitly typed.**

```gdscript
# ✅ CORRECT
var current_velocity: float = 0.0
func calculate_normal() -> Vector2:
@onready var chassis: RigidBody2D = $Chassis

# ❌ WRONG
var current_velocity = 0.0  # Missing type hint
func calculate_normal():     # Missing return type
```

### 4. Inheritance & Imports

```gdscript
# Every script starts with extends
extends Node2D

# Use @onready for scene tree references (not _ready assignments)
@onready var ray_left: RayCast2D = $WheelLeft/GroundDetector

# Access global constants via Autoload singleton
GlobalConstants.ADHESION_VELOCITY_THRESHOLD
```

### 5. Documentation Style

```gdscript
## Script-level documentation (double hash)
## Explains the purpose and role of this script

# Section dividers for organization
# ========================================
# PHYSICS PARAMETERS
# ========================================

func _handle_input(delta: float) -> void:
	"""Process player input for movement"""
	# Implementation details (single hash for inline comments)
```

### 6. Error Handling & Control Flow

- **Use guard clauses** for early returns
- **Avoid exceptions** - GDScript prefers conditional validation
- **Check states explicitly** before applying logic

```gdscript
func _draw() -> void:
	if not GlobalConstants.debug_draw_enabled:
		return  # Guard clause for early exit
	
	# Draw logic here...
```

---

## 📂 Project Structure

```
.
├── assets/                 # Raw assets (sprites, audio)
│   └── sprites/
├── docs/                   # Engineering & design documentation
│   ├── 01_Game_design.md   # Game mechanics & rules
│   ├── 02_Architecture.md  # Physics implementation details
│   ├── 03_Roadmap.md       # Development phases
│   └── 04_POC_Setup.md     # POC testing instructions
├── src/                    # Source code (scenes & scripts)
│   ├── _core/              # Autoloads & global managers
│   │   └── global_constants.gd  # Centralized config values
│   ├── components/         # Reusable behaviors
│   │   └── adhesion_detector/
│   ├── entities/           # Game objects (vehicle, obstacles)
│   │   └── vehicle/
│   │       ├── vehicle.tscn
│   │       └── vehicle_controller.gd
│   ├── levels/             # Maps & building blocks
│   │   ├── blocks/         # Modular track pieces
│   │   └── test/           # Physics sandboxes (POC)
│   │       └── poc_physics.tscn
│   └── ui/                 # HUD & interfaces
│       └── debug/
└── tools/                  # EditorScripts & dev tools
```

### Architectural Principles

1. **Feature-based organization**: Group related `.gd` and `.tscn` files together
2. **No magic numbers**: All tunable values belong in `GlobalConstants.gd`
3. **Component composition**: Prefer small, reusable scripts over monolithic controllers
4. **Collision-free chassis**: Only wheels have collision shapes to prevent "belly scraping"

---

## 🔧 Development Patterns

### Global Constants Access

**NEVER hardcode physics/gameplay values.** Always use `GlobalConstants`.

```gdscript
# ✅ CORRECT
if current_velocity > GlobalConstants.ADHESION_VELOCITY_THRESHOLD:

# ❌ WRONG
if current_velocity > 300.0:  # Magic number
```

### Physics Update Cycle

Follow the separation pattern used in `vehicle_controller.gd`:

```gdscript
func _physics_process(delta: float) -> void:
	_update_physics_state()   # 1. Read sensors & calculate state
	_handle_input(delta)       # 2. Process player input
	_apply_adhesion_logic()    # 3. Apply forces based on state
```

### Debug Visualization

Implement `_draw()` for complex physics entities:

```gdscript
func _draw() -> void:
	if not GlobalConstants.debug_draw_enabled:
		return
	
	# Draw velocity vectors, normals, etc.
	draw_line(Vector2.ZERO, velocity_vector, Color.YELLOW, 2.0)
```

Call `queue_redraw()` when state changes.

---

## 🎯 Current Implementation Status

### ✅ Implemented
- Global constants system (`GlobalConstants.gd`)
- Basic vehicle structure (dumbbell model with RigidBody2D)
- Ground detection via RayCast2D
- Adhesion state machine (velocity-threshold based)
- Debug visualization framework

### 🚧 In Progress (TODOs in code)
- Motor force application (ground locomotion)
- Air control (chassis torque)
- Path2D to CollisionPolygon2D baking tool

### ❌ Not Yet Started
- Track generation tooling
- UI/HUD systems
- Split-screen multiplayer
- Automated testing (GUT integration)

---

## 📋 Common Tasks

### Adding a New Constant

1. Open `src/_core/global_constants.gd`
2. Add to appropriate section with type hint and documentation
3. Use `##` for doc comments explaining purpose and units

```gdscript
## Maximum angular velocity (rad/s) for air rotation
const MAX_AIR_ROTATION_SPEED: float = 3.14
```

### Creating a New Component

1. Create folder in `src/components/[component_name]/`
2. Add `[component_name].gd` with proper `extends` declaration
3. Follow strict typing and documentation patterns
4. If it has tunable values, add them to `GlobalConstants`

### Modifying Physics Behavior

1. **Read documentation first**: `docs/02_Architecture.md`
2. Adjust constants in `GlobalConstants.gd` (NOT in component code)
3. Test in `poc_physics.tscn` via F5
4. Use debug drawing to visualize changes

---

## ⚠️ Critical Rules

### DO
- ✅ Use explicit type hints on ALL declarations
- ✅ Document scripts with `##` and functions with `"""`
- ✅ Centralize constants in `GlobalConstants.gd`
- ✅ Use `@onready` for node references
- ✅ Implement `_draw()` for complex physics debugging
- ✅ Follow snake_case naming consistently
- ✅ Separate state calculation from force application

### DON'T
- ❌ Hardcode magic numbers in component scripts
- ❌ Use untyped variables or function signatures
- ❌ Add collision shapes to the chassis RigidBody
- ❌ Modify global gravity directly (use `gravity_scale`)
- ❌ Create monolithic scripts (prefer small components)
- ❌ Skip documentation for public functions

---

## 🔍 Key Files to Review

Before making changes, understand these core files:

1. **`src/_core/global_constants.gd`** - All physics parameters
2. **`src/entities/vehicle/vehicle_controller.gd`** - Main physics implementation
3. **`docs/02_Architecture.md`** - Custom gravity algorithm explained
4. **`project.godot`** - Engine configuration and autoloads

---

## 🐛 Debugging Tips

### Enable Visual Debug Overlays

```gdscript
# In any component's _draw() method
if GlobalConstants.debug_draw_enabled:
	draw_line(start, end, Color.CYAN, 2.0)
	queue_redraw()  # Update every frame
```

### Common Issues

| Problem | Likely Cause | Solution |
|---------|--------------|----------|
| Vehicle falls through walls | Adhesion velocity too high | Lower `ADHESION_VELOCITY_THRESHOLD` |
| Chassis gets stuck | Collision layer not disabled | Set `chassis.collision_layer = 0` |
| Jittery wall-running | Collision polygon not smooth | Check Path2D bake interval |
| No motor response | PinJoint motor not enabled | Verify joint configuration in scene |

---

## 📚 Additional Resources

- **Godot Docs**: https://docs.godotengine.org/en/stable/
- **GDScript Style Guide**: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html
- **Project README**: `/README.md`
- **Architecture Doc**: `/docs/02_Architecture.md`

---

**Remember**: This is a physics-driven game. Always test changes in the POC scene and use debug visualization to verify behavior before moving to production implementation.
