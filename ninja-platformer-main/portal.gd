extends Area2D

@export var target_spawn_id := "world2_start"

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		GameManager.next_spawn_id = target_spawn_id
		get_tree().change_scene_to_file("res://world2.tscn")
