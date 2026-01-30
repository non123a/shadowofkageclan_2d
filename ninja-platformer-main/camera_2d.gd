extends Camera2D

@export var follow_speed_x: float = 5.0
@export var follow_speed_y: float = 3.0

@export var fixed_y: float = 120.0
@export var y_offset: float = -20.0
@export var y_threshold: float = 40.0

func _process(delta: float) -> void:
	var player := get_parent() as Node2D
	if player == null:
		return

	# ---- X follows smoothly ----
	var target_x: float = player.global_position.x
	global_position.x = lerp(
		global_position.x,
		target_x,
		follow_speed_x * delta
	)

	# ---- Y follows slowly when needed ----
	var desired_y: float = player.global_position.y + y_offset
	var diff_y: float = desired_y - global_position.y

	if abs(diff_y) > y_threshold:
		# Slow follow during big jumps/falls
		global_position.y = lerp(
			global_position.y,
			desired_y,
			follow_speed_y * delta
		)
	else:
		# Gently return to baseline
		global_position.y = lerp(
			global_position.y,
			fixed_y + y_offset,
			follow_speed_y * delta
		)
