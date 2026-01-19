extends Camera2D

## Camera follower for vehicle testing
## Smoothly tracks the vehicle's position

@onready var vehicle: Node2D = get_parent()

func _process(delta: float) -> void:
	if vehicle:
		global_position = vehicle.global_position
