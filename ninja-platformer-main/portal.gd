
extends Area2D

@export var target_scene := "res://world_2.tscn"
func _ready() -> void:
	print("portal work")
func _on_body_entered(body):
	if body.is_in_group("player"):
		print("detect player")
		get_tree().change_scene_to_file(target_scene)
