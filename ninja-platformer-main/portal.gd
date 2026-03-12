#
#extends Area2D
#
#@export var target_scene := "res://world_2.tscn"
#func _ready() -> void:
	#print("portal work")
#func _on_body_entered(body):
	#if body.is_in_group("player"):
		#print("detect player")
		#get_tree().change_scene_to_file(target_scene)
extends Area2D

@export var target_scene := "res://world_2.tscn"

var is_open = false

func _ready() -> void:
	print("portal ready but locked")

func open_portal():
	is_open = true
	print("portal opened")

func _on_body_entered(body):
	if body.is_in_group("player") and is_open:
		print("detect player")
		get_tree().change_scene_to_file(target_scene)
