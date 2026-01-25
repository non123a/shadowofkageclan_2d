extends CharacterBody2D

enum STATE { IDLE, CHASE, ATTACK, HIT }
@onready var hurtbox: Hurtbox = $Anchor/Hurtbox
@export var stats: Stats
@export var attack_cooldown := 0.8  # seconds
var can_attack := true
@export var max_speed := 80
@export var gravity := 900
@export var attack_range := 35
@export var attack_duration := 0.15
@onready var animation_player_upper: AnimationPlayer = $AnimationPlayerUpper
@onready var animation_player_lower: AnimationPlayer = $AnimationPlayerLower

var state = STATE.IDLE
var player: CharacterBody2D = null

@onready var detection_area: Area2D = $DetectionArea
@onready var hitbox: Area2D = $Anchor/Hitbox
@onready var anchor: Node2D = $Anchor

func _ready():
	anchor.scale.x = -1
	hitbox.monitoring = false

	hurtbox.hurt.connect(func(other_hitbox: Hitbox):
		if stats == null:
			push_error("Enemy stats is NULL!")
			return

		stats.health -= other_hitbox.damage
		print("Enemy hit! Health:", stats.health)

		if stats.health <= 0:
			queue_free()
		)


	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)



func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	match state:
		STATE.IDLE:
			velocity.x = 0

		STATE.CHASE:
			chase_player()

		STATE.ATTACK:
			velocity.x = 0

	move_and_slide()

func chase_player():
	if not player:
		state = STATE.IDLE
		return

	var dir = sign(player.global_position.x - global_position.x)
	anchor.scale.x = dir
	velocity.x = dir * max_speed

	if global_position.distance_to(player.global_position) <= attack_range:
		state = STATE.ATTACK
		attack()
func attack():
	can_attack = false
	velocity.x = 0

	# Face player
	if player:
		anchor.scale.x = sign(player.global_position.x - global_position.x)

	# Play attack animation
	if animation_player_upper:
		animation_player_upper.play("attack")

	# HITBOX TIMING (short + precise)
	hitbox.monitoring = true
	await get_tree().create_timer(0.12).timeout
	hitbox.monitoring = false

	# Cooldown before next attack
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	state = STATE.CHASE

#func attack():
	#hitbox.monitoring = true
	#await get_tree().create_timer(attack_duration).timeout
	#hitbox.monitoring = false
#
	#if player:
		#state = STATE.CHASE
	#else:
		#state = STATE.IDLE
#func attack():
	## Face player
	#if player:
		#anchor.scale.x = sign(player.global_position.x - global_position.x)
#
	## Play sword animation
	#if animation_player_upper:
		#animation_player_upper.play("attack")
#
	#hitbox.monitoring = true
	#await get_tree().create_timer(attack_duration).timeout
	#hitbox.monitoring = false
#
	#state = STATE.CHASE
#
#
##func _on_body_entered(body):
	##if body.name == "Player":
		##player = body
		##state = STATE.CHASE
		##
##func _on_body_entered(body):
	##print("Detected body:", body.name)
##
	##if body.name == "player":
		##player = body
		##state = STATE.CHASE
func _on_body_entered(body):
	print("Detected body:", body.name)

	if body is CharacterBody2D and body.is_in_group("player"):
		player = body
		state = STATE.CHASE


func _on_body_exited(body):
	if body == player:
		player = null
		state = STATE.IDLE
