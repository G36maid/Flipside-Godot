extends Node

## Global physics and gameplay constants for Flipside
## These values control the core adhesion mechanics and vehicle behavior

# ========================================
# PHYSICS PARAMETERS
# ========================================

## Minimum velocity (px/s) required to maintain surface adhesion
## Below this threshold, vehicle loses grip and falls
const ADHESION_VELOCITY_THRESHOLD: float = 300.0

## Hysteresis buffer (px/s) to prevent flickering at threshold boundary
## Vehicle must drop to (THRESHOLD - HYSTERESIS) to detach
## or exceed (THRESHOLD + HYSTERESIS) to attach
const ADHESION_HYSTERESIS: float = 50.0

## Downforce multiplier applied when adhering to surfaces
## This should be gentle - just enough to keep wheels pressed to ground
## against collision response jitter (not to fight gravity, that's cancelled)
const ADHESION_FORCE_MULTIPLIER: float = 200.0

## Global gravity scale (Godot default is 980 px/s²)
const GRAVITY: float = 980.0

# ========================================
# VEHICLE PARAMETERS
# ========================================

## Mass of the chassis (center body)
const CHASSIS_MASS: float = 1.0

## Mass of each wheel
const WHEEL_MASS: float = 0.5

## Wheel friction coefficient (ground traction)
## Lower values = less deceleration, higher values = more grip
## Range: 0.0 (ice) to 1.0 (maximum grip)
const WHEEL_FRICTION: float = 0.1

## Motor torque applied to wheels when on ground
const WHEEL_MOTOR_TORQUE: float = 5000.0

## Torque applied to chassis when airborne (for rotation control)
## With chassis inertia ~167, this gives ~4.8 rad/s² angular acceleration
## (allows ~1.3s for full rotation, responsive but controllable)
const AIR_TORQUE: float = 800.0

# ========================================
# DETECTION PARAMETERS
# ========================================

## RayCast length for ground detection (from wheel centers)
## Extended beyond wheel radius to detect "near ground" state (prevents bounce disconnect)
## Wheel radius = 16px, so 64px gives 48px of tolerance below wheel
const GROUND_DETECTION_LENGTH: float = 64.0

## Ground proximity threshold (px) - how far wheel can be from ground and still "adhere"
## This allows vehicle to maintain adhesion even during minor bounce/separation
const GROUND_PROXIMITY_THRESHOLD: float = 32.0

## Maximum angle (degrees) between wheels' normals to consider "aligned"
const MAX_NORMAL_DEVIATION: float = 45.0

# ========================================
# DEBUG SETTINGS
# ========================================

## Enable visual debug overlays (velocity vectors, normals, etc.)
var debug_draw_enabled: bool = true

## Color for adhesion force vector visualization
const DEBUG_ADHESION_COLOR: Color = Color.CYAN

## Color for velocity vector visualization
const DEBUG_VELOCITY_COLOR: Color = Color.YELLOW
