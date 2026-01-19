extends Node2D

## Vehicle Controller - Manages the "Dumbbell" physics structure
## Implements velocity-based adhesion mechanics following Godot best practices
## 
## Architecture:
## - Uses apply_central_force() in _physics_process() for adhesion forces
## - RayCast2D detectors on each wheel for ground normal extraction
## - Hysteresis buffer prevents flickering between adhesion states
## - Separate control logic for ground (motor) vs air (torque) states

@onready var chassis: RigidBody2D = $Chassis
@onready var wheel_left: RigidBody2D = $WheelLeft
@onready var wheel_right: RigidBody2D = $WheelRight
@onready var ray_left: RayCast2D = $WheelLeft/GroundDetector
@onready var ray_right: RayCast2D = $WheelRight/GroundDetector
@onready var joint_left: PinJoint2D = $JointLeft
@onready var joint_right: PinJoint2D = $JointRight

# ========================================
# PHYSICS STATE
# ========================================

## Current adhesion state (velocity-threshold based)
var is_adhered: bool = false

## Surface normal vector (averaged from both wheel raycasts)
var surface_normal: Vector2 = Vector2.UP

## Average velocity magnitude across both wheels
var current_velocity: float = 0.0

## Control mode based on ground contact
enum ControlState { GROUND, AIR }
var control_state: ControlState = ControlState.AIR

# ========================================
# INITIALIZATION
# ========================================

func _ready() -> void:
	# Disable chassis collision (prevent belly scraping)
	chassis.collision_layer = 0
	chassis.collision_mask = 0
	
	# Set up physics materials for wheels (high friction, no bounce)
	var wheel_material: PhysicsMaterial = PhysicsMaterial.new()
	wheel_material.friction = GlobalConstants.WHEEL_FRICTION
	wheel_material.bounce = 0.0
	wheel_left.physics_material_override = wheel_material
	wheel_right.physics_material_override = wheel_material
	
	# Add damping to prevent bouncing and oscillation
	wheel_left.linear_damp = 0.5
	wheel_right.linear_damp = 0.5
	chassis.linear_damp = 0.3
	chassis.angular_damp = 1.0
	
	# Increase contact detection for better RayCast stability
	wheel_left.max_contacts_reported = 8
	wheel_right.max_contacts_reported = 8
	
	# Configure PinJoint motors (disabled by default, enabled on ground)
	joint_left.motor_enabled = false
	joint_right.motor_enabled = false
	
	# TEST: Give initial velocity to test adhesion mechanics
	# Increased to 600 px/s for longer observation time
	await get_tree().physics_frame  # Wait one frame for physics to initialize
	wheel_left.linear_velocity = Vector2(600, 0)
	wheel_right.linear_velocity = Vector2(600, 0)
	chassis.linear_velocity = Vector2(600, 0)

# ========================================
# PHYSICS LOOP
# ========================================

# Debug tracking
var _last_adhered_state: bool = false
var _debug_frame_counter: int = 0

func _physics_process(delta: float) -> void:
	_update_physics_state()
	_handle_input(delta)
	_apply_adhesion_forces()
	queue_redraw()  # Trigger debug visualization
	
	# Debug: Print state changes
	_debug_frame_counter += 1
	if is_adhered != _last_adhered_state:
		print("[Frame %d] State changed: %s → %s | Velocity: %.1f | RayL: %s | RayR: %s | WheelLeft Y: %.1f" % [
			_debug_frame_counter,
			"GROUND" if _last_adhered_state else "AIR",
			"GROUND" if is_adhered else "AIR",
			current_velocity,
			"HIT" if ray_left.is_colliding() else "MISS",
			"HIT" if ray_right.is_colliding() else "MISS",
			wheel_left.global_position.y
		])
		_last_adhered_state = is_adhered

# ========================================
# STATE DETECTION
# ========================================

func _update_physics_state() -> void:
	"""
	Read sensor data and update adhesion state.
	Uses hysteresis buffer to prevent rapid flickering.
	"""
	# Calculate average velocity from both wheels
	var vel_left: Vector2 = wheel_left.linear_velocity
	var vel_right: Vector2 = wheel_right.linear_velocity
	current_velocity = (vel_left + vel_right).length() / 2.0
	
	# Detect ground contact and extract surface normals
	var left_grounded: bool = ray_left.is_colliding()
	var right_grounded: bool = ray_right.is_colliding()
	
	# Calculate combined surface normal
	if left_grounded and right_grounded:
		var normal_left: Vector2 = ray_left.get_collision_normal()
		var normal_right: Vector2 = ray_right.get_collision_normal()
		surface_normal = (normal_left + normal_right).normalized()
	elif left_grounded:
		surface_normal = ray_left.get_collision_normal()
	elif right_grounded:
		surface_normal = ray_right.get_collision_normal()
	else:
		surface_normal = Vector2.UP  # Default fallback
	
	# Update adhesion state with hysteresis
	_update_adhesion_state(left_grounded or right_grounded)
	
	# Update control mode
	control_state = ControlState.GROUND if is_adhered else ControlState.AIR

func _update_adhesion_state(grounded: bool) -> void:
	"""
	Apply velocity-based adhesion with hysteresis buffer.
	Prevents rapid on/off flickering at threshold boundary.
	"""
	if not grounded:
		is_adhered = false
		return
	
	var threshold: float = GlobalConstants.ADHESION_VELOCITY_THRESHOLD
	var hysteresis: float = GlobalConstants.ADHESION_HYSTERESIS
	
	if is_adhered:
		# Currently adhered - check if we fall below lower threshold
		if current_velocity < (threshold - hysteresis):
			is_adhered = false
	else:
		# Currently falling - check if we exceed upper threshold
		if current_velocity > (threshold + hysteresis):
			is_adhered = true

# ========================================
# INPUT HANDLING
# ========================================

func _handle_input(delta: float) -> void:
	"""
	Process player input with mode-dependent control.
	Ground: Motor torque on wheels (friction-based propulsion)
	Air: Torque on chassis (rotation control for landing)
	"""
	var input_dir: float = Input.get_axis("ui_left", "ui_right")
	
	if control_state == ControlState.GROUND:
		# Ground mode: Enable motors and set target velocity
		joint_left.motor_enabled = true
		joint_right.motor_enabled = true
		
		# Apply motor force (TODO: Replace with direct wheel torque if motors unstable)
		var motor_speed: float = input_dir * GlobalConstants.WHEEL_MOTOR_TORQUE
		joint_left.motor_target_velocity = motor_speed
		joint_right.motor_target_velocity = motor_speed
	else:
		# Air mode: Disable motors, apply chassis torque for rotation
		joint_left.motor_enabled = false
		joint_right.motor_enabled = false
		
		var air_torque: float = input_dir * GlobalConstants.AIR_TORQUE
		chassis.apply_torque(air_torque)

# ========================================
# ADHESION FORCE APPLICATION
# ========================================

func _apply_adhesion_forces() -> void:
	"""
	Apply custom gravity forces when adhered to surfaces.
	Uses apply_central_force() which is frame-rate independent.
	
	When adhered:
	  1. Apply downforce along surface normal
	  2. Cancel global gravity with opposite force
	
	When falling:
	  Global gravity applies automatically (no action needed)
	"""
	if not is_adhered:
		return  # Let Godot's built-in gravity work naturally
	
	# Calculate adhesion downforce
	var adhesion_force: Vector2 = -surface_normal * GlobalConstants.ADHESION_FORCE_MULTIPLIER
	
	# Calculate gravity cancellation force (F = ma)
	var gravity_vector: Vector2 = Vector2(0, GlobalConstants.GRAVITY)
	var cancel_gravity_left: Vector2 = -gravity_vector * wheel_left.mass
	var cancel_gravity_right: Vector2 = -gravity_vector * wheel_right.mass
	var cancel_gravity_chassis: Vector2 = -gravity_vector * chassis.mass
	
	# Apply forces to all rigid bodies
	wheel_left.apply_central_force(adhesion_force + cancel_gravity_left)
	wheel_right.apply_central_force(adhesion_force + cancel_gravity_right)
	chassis.apply_central_force(adhesion_force + cancel_gravity_chassis)

# ========================================
# DEBUG VISUALIZATION
# ========================================

func _draw() -> void:
	"""
	Debug overlay showing physics state vectors.
	Toggle with GlobalConstants.debug_draw_enabled
	"""
	if not GlobalConstants.debug_draw_enabled:
		return
	
	# Draw velocity vector (yellow)
	var vel_normalized: Vector2 = chassis.linear_velocity.normalized() * 50.0
	draw_line(Vector2.ZERO, vel_normalized, GlobalConstants.DEBUG_VELOCITY_COLOR, 2.0)
	
	# Draw surface normal when adhered (cyan)
	if is_adhered:
		var normal_vis: Vector2 = surface_normal * 50.0
		draw_line(Vector2.ZERO, normal_vis, GlobalConstants.DEBUG_ADHESION_COLOR, 2.0)
	
	# Draw RayCast detectors (red = not colliding, green = colliding)
	var ray_left_color: Color = Color.RED if not ray_left.is_colliding() else Color.GREEN
	var ray_right_color: Color = Color.RED if not ray_right.is_colliding() else Color.GREEN
	
	var ray_left_start: Vector2 = wheel_left.position
	var ray_left_end: Vector2 = wheel_left.position + ray_left.target_position
	draw_line(ray_left_start, ray_left_end, ray_left_color, 2.0)
	
	var ray_right_start: Vector2 = wheel_right.position
	var ray_right_end: Vector2 = wheel_right.position + ray_right.target_position
	draw_line(ray_right_start, ray_right_end, ray_right_color, 2.0)
	
	# Draw collision points if detected
	if ray_left.is_colliding():
		var collision_point: Vector2 = ray_left.get_collision_point() - global_position
		draw_circle(collision_point, 4.0, Color.YELLOW)
	
	if ray_right.is_colliding():
		var collision_point: Vector2 = ray_right.get_collision_point() - global_position
		draw_circle(collision_point, 4.0, Color.YELLOW)
	
	# Draw state text
	var state_text: String = "Vel: %.0f | Adhered: %s | Mode: %s | RayL: %s | RayR: %s" % [
		current_velocity,
		"YES" if is_adhered else "NO",
		"GROUND" if control_state == ControlState.GROUND else "AIR",
		"HIT" if ray_left.is_colliding() else "MISS",
		"HIT" if ray_right.is_colliding() else "MISS"
	]
	draw_string(ThemeDB.fallback_font, Vector2(-80, -70), state_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
