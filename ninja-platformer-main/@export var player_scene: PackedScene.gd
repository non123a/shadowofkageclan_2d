extends Node

@export var player_scene: PackedScene

var next_spawn_id: String = "level1_start"

#var next_spawn_id: String = ""
var current_spawn_point: Vector2 = Vector2.ZERO

func change_level(scene_path: String, spawn_id: String):
	next_spawn_id = spawn_id
	get_tree().change_scene_to_file(scene_path)

func on_level_loaded():
	find_spawn_point()
	spawn_player()

func find_spawn_point():
	var world := get_tree().current_scene

	for child in world.get_children():
		if child is Node2D and child.has_method("get"):
			if child.has_meta("spawn_id"):
				if child.spawn_id == next_spawn_id:
					current_spawn_point = child.global_position
					return

	push_error("Spawn point not found: " + next_spawn_id)

func spawn_player():
	var world := get_tree().current_scene

	# Remove old player
	for child in world.get_children():
		if child.is_in_group("player"):
			child.queue_free()

	var player = player_scene.instantiate()
	world.add_child(player)
	player.global_position = current_spawn_point

func respawn_player():
	spawn_player()
