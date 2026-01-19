extends Node

## Global physics and gameplay constants for Flipside
## These values control the core adhesion mechanics and vehicle behavior

# ========================================
# PHYSICS PARAMETERS
# ========================================

## Minimum velocity (px/s) required to maintain surface adhesion
## Below this threshold, vehicle loses grip and falls
const ADHESION_VELOCITY_THRESHOLD: float = 300.0

## Downforce multiplier applied when adhering to surfaces
## Higher values = stronger grip to walls/ceilings
const ADHESION_FORCE_MULTIPLIER: float = 2000.0

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
const WHEEL_FRICTION: float = 1.0

## Motor torque applied to wheels when on ground
const WHEEL_MOTOR_TORQUE: float = 5000.0

## Torque applied to chassis when airborne (for rotation control)
const AIR_TORQUE: float = 8000.0

# ========================================
# DETECTION PARAMETERS
# ========================================

## RayCast length for ground detection (from wheel centers)
const GROUND_DETECTION_LENGTH: float = 32.0

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
