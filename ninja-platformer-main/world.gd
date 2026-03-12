extends Node2D

@export var push_strength: float = 300.0
var bodies_inside: Array[CharacterBody2D] = []

var key_enemy = null

func _ready():
	MusicManager.play_music(
		load("res://sounding/startOftheGame.mp3")
	)
	var enemies = get_tree().get_nodes_in_group("enemy")
	key_enemy = enemies.pick_random()
	
	
func enemy_died(enemy):
	if enemy == key_enemy:
		$Portal.open_portal()
	
	
func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		print("Entered barrier:", body.name)
		bodies_inside.append(body)

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		print("Exited barrier:", body.name)
		bodies_inside.erase(body)

func _physics_process(delta: float) -> void:
	for character in bodies_inside:
		if not is_instance_valid(character):
			continue

		var dir: int = sign(character.global_position.x - global_position.x)
		if dir == 0:
			dir = -1

		character.global_position.x += dir * push_strength * delta
