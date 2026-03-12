extends CharacterBody2D

enum STATE { IDLE, PATROL, CHASE, ATTACK, HIT }

@export var patrol_range: float = 80.0
@export var patrol_speed: float = 40.0

@export var first_attack_delay := 0.5
var first_attack_ready := false

@export var min_wait_time: float = 0.6
@export var max_wait_time: float = 1.4

@export var min_look_count: int = 1
@export var max_look_count: int = 2

var left_limit: float
var right_limit: float
var patrol_dir: int = 1

var patrol_state := "walk"  # "walk", "wait"
var wait_timer: float = 0.0
var look_timer: float = 0.0
var looks_left: int = 0

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

func _ready():
	anchor.scale.x = -1
	hitbox.monitoring = false
	
	left_limit = global_position.x - patrol_range
	right_limit = global_position.x + patrol_range

	# Random initial direction
	patrol_dir = -1 if randf() < 0.5 else 1

	state = STATE.PATROL

	randomize()

	
	
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
			get_parent().enemy_died(self)
			queue_free()
	)

	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	match state:
		STATE.PATROL:
			patrol(delta)

		STATE.CHASE:
			chase_player()

		STATE.ATTACK:
			velocity.x = 0

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
	if can_attack and first_attack_ready and state != STATE.ATTACK:
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
	
func start_first_attack_delay() -> void:
	await get_tree().create_timer(first_attack_delay).timeout
	first_attack_ready = true

func _on_body_entered(body):
	print("Detected body:", body.name)
	if body.is_in_group("player"):
		MusicManager.play_music(
			load("res://sounding/enemy_attacking.mp3")
		)
	if body is CharacterBody2D and body.is_in_group("player"):
		player = body
		state = STATE.CHASE
		# 🔥 IMPORTANT: cancel patrol logic
		patrol_state = "walk"
		wait_timer = 0.0
		look_timer = 0.0
		looks_left = 0
		
		first_attack_ready = false
		start_first_attack_delay()

func _on_body_exited(body):
	if body == player:
		player = null
		state = STATE.PATROL
		
func start_patrol_wait() -> void:
	patrol_state = "wait"
	velocity.x = 0

	wait_timer = randf_range(min_wait_time, max_wait_time)
	looks_left = randi_range(min_look_count, max_look_count)
	look_timer = wait_timer / max(1, looks_left * 2)

func patrol(delta: float) -> void:
	match patrol_state:

		# ================= WALK =================
		"walk":
			velocity.x = patrol_dir * patrol_speed
			anchor.scale.x = patrol_dir

			if animation_player_lower and animation_player_lower.current_animation != "run":
				animation_player_lower.play("run")

			# Hit patrol edge?
			if patrol_dir == -1 and global_position.x <= left_limit:
				start_patrol_wait()
			elif patrol_dir == 1 and global_position.x >= right_limit:
				start_patrol_wait()

		# ================= WAIT / LOOK =================
		"wait":
			velocity.x = 0

			if animation_player_lower and animation_player_lower.current_animation != "stand":
				animation_player_lower.play("stand")

			wait_timer -= delta
			look_timer -= delta

			# Look left/right
			if look_timer <= 0.0 and looks_left > 0:
				patrol_dir *= -1
				anchor.scale.x = patrol_dir
				looks_left -= 1
				look_timer = randf_range(0.2, 0.4)

			# Resume walking
			if wait_timer <= 0.0:
				patrol_dir *= -1
				patrol_state = "walk"
