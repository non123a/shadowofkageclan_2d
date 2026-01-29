extends Area2D

@export var push_distance: float = 20.0
var bodies_inside: Array[CharacterBody2D] = []

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		bodies_inside.append(body)

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		bodies_inside.erase(body)

func _physics_process(delta: float) -> void:
	for character in bodies_inside:
		if not is_instance_valid(character):
			continue

		var dir: int = sign(character.global_position.x - global_position.x)
		if dir == 0:
			dir = -1

		# CONTINUOUS PUSH
		character.global_position.x += dir * push_distance * delta
