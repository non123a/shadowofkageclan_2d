extends Camera2D

@export var follow_speed := 8.0
@export var fixed_y := 120.0   # Set this to your stage height

func _process(delta):
	var target_x = get_parent().global_position.x
	global_position.x = lerp(global_position.x, target_x, follow_speed * delta)
	global_position.y = fixed_y
