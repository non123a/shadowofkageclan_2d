extends Area2D

@onready var hitbox: Hitbox = $Hitbox
@export var damage := 1

@export var speed := 200
var direction := Vector2.ZERO
@export var lifetime := 0.5   # 👈 tweak this (IMPORTANT)
func _ready():
	hitbox.damage = damage
	await get_tree().create_timer(lifetime).timeout
	queue_free()


func _process(delta):
	#position += direction * speed * delta
	position += direction * speed * delta
	rotation += 30 * delta
	if Input.is_action_just_pressed("throw"):
		print("THROW PRESSED")
##func _process(delta):
	#position += direction * speed * delta
	#rotation += 10 * delta
#func _on_body_entered(body):
	#if body.is_in_group("enemy"):
		#body.queue_free() # or damage system later
	#queue_free() # destroy shuriken
func _on_body_entered(body):
	print("COLLIDED WITH:", body.name)
	if body.is_in_group("player"):
		return

	#if body.is_in_group("enemy"):
		#print("HIT ENEMY")
		#body.queue_free()
		#queue_free()
		
	queue_free()
