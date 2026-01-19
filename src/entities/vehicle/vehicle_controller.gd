extends Node2D

## Vehicle Controller - Manages the "Dumbbell" physics structure
## Handles adhesion logic, input, and motor control for the vehicle

@onready var chassis: RigidBody2D = $Chassis
@onready var wheel_left: RigidBody2D = $WheelLeft
@onready var wheel_right: RigidBody2D = $WheelRight
@onready var ray_left: RayCast2D = $WheelLeft/GroundDetector
@onready var ray_right: RayCast2D = $WheelRight/GroundDetector

# Physics state
var is_adhered: bool = false
var surface_normal: Vector2 = Vector2.UP
var current_velocity: float = 0.0

func _ready() -> void:
	# Disable chassis collision layer (prevent belly scraping)
	chassis.collision_layer = 0
	chassis.collision_mask = 0

func _physics_process(delta: float) -> void:
	_update_physics_state()
	_handle_input(delta)
	_apply_adhesion_logic()

func _update_physics_state() -> void:
	"""Calculate current velocity and detect ground"""
	# Average velocity from both wheels
	current_velocity = (wheel_left.linear_velocity + wheel_right.linear_velocity).length() / 2.0
	
	# Detect ground and calculate surface normal
	var left_grounded = ray_left.is_colliding()
	var right_grounded = ray_right.is_colliding()
	
	if left_grounded and right_grounded:
		var normal_left = ray_left.get_collision_normal()
		var normal_right = ray_right.get_collision_normal()
		surface_normal = (normal_left + normal_right).normalized()
		is_adhered = current_velocity > GlobalConstants.ADHESION_VELOCITY_THRESHOLD
	elif left_grounded:
		surface_normal = ray_left.get_collision_normal()
		is_adhered = current_velocity > GlobalConstants.ADHESION_VELOCITY_THRESHOLD
	elif right_grounded:
		surface_normal = ray_right.get_collision_normal()
		is_adhered = current_velocity > GlobalConstants.ADHESION_VELOCITY_THRESHOLD
	else:
		is_adhered = false
		surface_normal = Vector2.UP

func _handle_input(delta: float) -> void:
	"""Process player input for movement"""
	var input_dir = Input.get_axis("ui_left", "ui_right")
	
	# TODO: Implement ground/air control
	# Ground: Apply motor force to wheels
	# Air: Apply torque to chassis

func _apply_adhesion_logic() -> void:
	"""Apply custom gravity based on adhesion state"""
	if is_adhered:
		# Disable global gravity and apply surface adhesion
		wheel_left.gravity_scale = 0.0
		wheel_right.gravity_scale = 0.0
		chassis.gravity_scale = 0.0
		
		# Apply downforce toward surface
		var adhesion_force = -surface_normal * GlobalConstants.ADHESION_FORCE_MULTIPLIER
		wheel_left.apply_central_force(adhesion_force)
		wheel_right.apply_central_force(adhesion_force)
		chassis.apply_central_force(adhesion_force)
	else:
		# Re-enable global gravity
		wheel_left.gravity_scale = 1.0
		wheel_right.gravity_scale = 1.0
		chassis.gravity_scale = 1.0

func _draw() -> void:
	"""Debug visualization"""
	if not GlobalConstants.debug_draw_enabled:
		return
	
	# Draw velocity vector
	var vel_normalized = chassis.linear_velocity.normalized() * 50
	draw_line(Vector2.ZERO, vel_normalized, GlobalConstants.DEBUG_VELOCITY_COLOR, 2.0)
	
	# Draw surface normal
	if is_adhered:
		draw_line(Vector2.ZERO, surface_normal * 50, GlobalConstants.DEBUG_ADHESION_COLOR, 2.0)
