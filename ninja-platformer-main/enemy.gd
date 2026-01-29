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
@onready var health_bar: ProgressBar = $Anchor/HealthBar

var state = STATE.IDLE
var player: CharacterBody2D = null

@onready var detection_area: Area2D = $DetectionArea
@onready var hitbox: Area2D = $Anchor/Hitbox
@onready var anchor: Node2D = $Anchor

#func _ready():
	#anchor.scale.x = -1
	#hitbox.monitoring = false
	## --- HealthBar setup ---
	#if stats != null and health_bar:
		#health_bar.max_value = stats.max_health
		#health_bar.value = stats.health
		#health_bar.visible = true
		#
		#
	#hurtbox.hurt.connect(func(other_hitbox: Hitbox):
		#if stats == null:
			#push_error("Enemy stats is NULL!")
			#return
#
	#stats.health -= other_hitbox.damage
	#stats.health = max(stats.health, 0)
#
	## Update health bar
	#if health_bar:
		#health_bar.value = stats.health
#
	#print("Enemy hit! Health:", stats.health)
#
	#if stats.health <= 0:
		#queue_free()
#
#
#
	#detection_area.body_entered.connect(_on_body_entered)
	#detection_area.body_exited.connect(_on_body_exited)
#
func _ready():
	anchor.scale.x = -1
	hitbox.monitoring = false

	# --- HealthBar setup ---
	if stats != null and health_bar:
		health_bar.max_value = stats.max_health
		health_bar.value = stats.health
		health_bar.visible = true

	hurtbox.hurt.connect(func(other_hitbox: Hitbox):
		if stats == null:
			push_error("Enemy stats is NULL!")
			return

		stats.health -= other_hitbox.damage
		stats.health = max(stats.health, 0)

		# Update health bar
		if health_bar:
			health_bar.value = stats.health

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
#func chase_player():
	#if not player:
		#state = STATE.IDLE
		#if animation_player_lower:
			#animation_player_lower.play("stand")
		#return
#
	## Player exists → chase
	#if animation_player_lower:
		#animation_player_lower.play("run")
#
	#var dir = sign(player.global_position.x - global_position.x)
	#anchor.scale.x = dir
	#velocity.x = dir * max_speed
#
	#if can_attack \
	#and state != STATE.ATTACK \
	#and global_position.distance_to(player.global_position) <= attack_range:
		#state = STATE.ATTACK
		#attack()
#
	#var dir1 = sign(player.global_position.x - global_position.x)
	#anchor.scale.x = dir
	#velocity.x = dir1 * max_speed
#
	## ONLY start attack if allowed
	#if can_attack \
	#and state != STATE.ATTACK \
	#and global_position.distance_to(player.global_position) <= attack_range:
		#state = STATE.ATTACK
		#attack()
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

#func attack():
	#can_attack = false
	#state = STATE.ATTACK
	#velocity.x = 0
#
	## Lock facing direction
	#if player:
		#anchor.scale.x = sign(player.global_position.x - global_position.x)
#
	## Play attack animation ONCE
	#if animation_player_upper:
		#animation_player_upper.play("attack")
#
	## Enable hitbox during swing
	#hitbox.monitoring = true
	#await get_tree().create_timer(0.12).timeout
	#hitbox.monitoring = false
#
	## WAIT for attack animation to finish
	#if animation_player_upper:
		#await animation_player_upper.animation_finished
#
	## Reset upper animation to match lower body
	#if animation_player_lower:
		#animation_player_upper.play(animation_player_lower.current_animation)
#
	## Cooldown before next attack
	#await get_tree().create_timer(attack_cooldown).timeout
	#can_attack = true
	#state = STATE.CHASE
#
#
##func chase_player():
	##if not player:
		##state = STATE.IDLE
		##return
##
	##var dir = sign(player.global_position.x - global_position.x)
	##anchor.scale.x = dir
	##velocity.x = dir * max_speed
##
	##if global_position.distance_to(player.global_position) <= attack_range:
		##state = STATE.ATTACK
		##attack()
##func attack():
	##can_attack = false
	##velocity.x = 0
##
	### Face player
	##if player:
		##anchor.scale.x = sign(player.global_position.x - global_position.x)
##
	### Play attack animation
	##if animation_player_upper:
		##animation_player_upper.play("attack")
##
	### HITBOX TIMING (short + precise)
	##hitbox.monitoring = true
	##await get_tree().create_timer(0.12).timeout
	##hitbox.monitoring = false
##
	### Cooldown before next attack
	##await get_tree().create_timer(attack_cooldown).timeout
	##can_attack = true
	##state = STATE.CHASE
##
###func attack():
	###hitbox.monitoring = true
	###await get_tree().create_timer(attack_duration).timeout
	###hitbox.monitoring = false
###
	###if player:
		###state = STATE.CHASE
	###else:
		###state = STATE.IDLE
###func attack():
	#### Face player
	###if player:
		###anchor.scale.x = sign(player.global_position.x - global_position.x)
###
	#### Play sword animation
	###if animation_player_upper:
		###animation_player_upper.play("attack")
###
	###hitbox.monitoring = true
	###await get_tree().create_timer(attack_duration).timeout
	###hitbox.monitoring = false
###
	###state = STATE.CHASE
###
###
####func _on_body_entered(body):
	####if body.name == "Player":
		####player = body
		####state = STATE.CHASE
		####
####func _on_body_entered(body):
	####print("Detected body:", body.name)
####
	####if body.name == "player":
		####player = body
		####state = STATE.CHASE
func _on_body_entered(body):
	print("Detected body:", body.name)

	if body is CharacterBody2D and body.is_in_group("player"):
		player = body
		state = STATE.CHASE


func _on_body_exited(body):
	if body == player:
		player = null
		state = STATE.IDLE
