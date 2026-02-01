
extends CharacterBody2D

enum STATE { IDLE, CHASE, ATTACK, HIT }
@onready var hurtbox: Hurtbox = $Anchor/Hurtbox


@export var max_health := 4
var health := max_health


@export var attack_cooldown := 0.5 # seconds
var can_attack := true

@export var knockback_force := 120.0
@export var knockback_up := 80.0

var can_take_damage: bool = true

@export var max_speed := 120
@export var gravity := 900
@export var attack_range := 50
@export var attack_duration := 0.15
@onready var animation_player_upper: AnimationPlayer = $AnimationPlayerUpper
@onready var animation_player_lower: AnimationPlayer = $AnimationPlayerLower
@onready var health_bar: ProgressBar = $Anchor/HealthBar

var state = STATE.IDLE
var player: CharacterBody2D = null

@onready var detection_area: Area2D = $DetectionArea
@onready var hitbox: Area2D = $Anchor/Hitbox
@onready var anchor: Node2D = $Anchor
func die():
	queue_free()

func _ready():
	anchor.scale.x = -1
	hitbox.monitoring = false
	health = max_health

	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
		health_bar.visible = true


	hurtbox.hurt.connect(func(other_hitbox: Hitbox):
		if not can_take_damage:
			return

		can_take_damage = false

		# Knockback
		var x_dir: int = sign(
			other_hitbox.global_position.direction_to(global_position).x
		)

		if x_dir == 0:
			x_dir = -1

		velocity.x = x_dir * knockback_force
		velocity.y = -knockback_up
		state = STATE.HIT

		# Damage
		health -= other_hitbox.damage
		health = max(health, 0)

		if health_bar:
			health_bar.value = health

		print("Boss hit! Health:", health)

		if health <= 0:
			die()
			return

		# Damage cooldown (prevents multi-hit spam)
		await get_tree().create_timer(0.2).timeout
		can_take_damage = true
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
		STATE.HIT:
			# Apply gravity manually
			if not is_on_floor():
				velocity.y += gravity * delta

			move_and_slide()

			# Recover once grounded
			if is_on_floor():
				state = STATE.CHASE


	move_and_slide()

func chase_player():
	if not player:
		state = STATE.IDLE
		if animation_player_lower:
			if animation_player_lower.current_animation != "stand":
				animation_player_lower.play("stand")
		return

	var distance := global_position.distance_to(player.global_position)

	# Always face player
	var dir = sign(player.global_position.x - global_position.x)
	anchor.scale.x = dir

	# ===== PLAYER IS FAR → RUN =====
	if distance > attack_range:
		velocity.x = dir * max_speed

		if animation_player_lower:
			if animation_player_lower.current_animation != "run":
				animation_player_lower.play("run")
		return

	# ===== PLAYER IS NEAR → WAIT (IDLE) =====
	velocity.x = 0

	if animation_player_lower:
		if animation_player_lower.current_animation != "stand":
			animation_player_lower.play("stand")

	# Attack ONLY when cooldown finishes
	if can_attack and state != STATE.ATTACK:
		state = STATE.ATTACK
		attack()
func attack():
	can_attack = false
	state = STATE.ATTACK
	velocity.x = 0

	# Lock facing direction
	if player:
		anchor.scale.x = sign(player.global_position.x - global_position.x)

	# Play attack animation (upper body)
	if animation_player_upper:
		animation_player_upper.play("attack")

	# Hitbox active during swing
	hitbox.monitoring = true
	await get_tree().create_timer(0.12).timeout
	hitbox.monitoring = false

	# WAIT for the swing to finish
	if animation_player_upper:
		await animation_player_upper.animation_finished

	# 🔴 IMPORTANT FIX ↓↓↓
	# As soon as the swing ends, go IDLE visually
	if animation_player_lower:
		if animation_player_lower.current_animation != "stand":
			animation_player_lower.play("stand")

	# Upper body should also return to idle
	if animation_player_upper:
		animation_player_upper.play("stand")

	# Cooldown (logic only, no animation change)
	await get_tree().create_timer(attack_cooldown).timeout

	can_attack = true
	state = STATE.CHASE

func _on_body_entered(body):
	print("Detected body:", body.name)

	if body is CharacterBody2D and body.is_in_group("player"):
		player = body
		state = STATE.CHASE
		MusicManager.play_music(
			load("res://sounding/world2_sounding.mp3")
		)

func _on_body_exited(body):
	if body == player:
		player = null
		state = STATE.IDLE
		
	
