extends CharacterBody2D

enum STATE {
	IDLE,
	CHASE,
	ATTACK,
	HIT,
	DASH_ATTACK,
	DODGE,
	INTRO
}
@export var max_health := 10
var arena_locked := false
@export var dash_speed := 400.0
@export var dash_distance := 120.0

@export var intro_delay := 2.0
@export var dodge_cooldown := 3.0
@onready var dash_audio: AudioStreamPlayer2D = $DashAudio
var can_dodge := true
var intro_done := false

@onready var hurtbox: Hurtbox = $Anchor/Hurtbox
@export var stats: Stats
@export var attack_cooldown := 0.5 # seconds
var can_attack := true

@export var knockback_force := 120.0
@export var knockback_up := 80.0


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

func _ready():
	if stats:
		stats.max_health = max_health
		stats.health = max_health

	anchor.scale.x = -1
	hitbox.monitoring = false

	# --- HealthBar setup ---
	if stats != null and health_bar:
		health_bar.max_value = stats.max_health
		health_bar.value = stats.health
		health_bar.visible = true

	hurtbox.hurt.connect(func(other_hitbox: Hitbox):
		if stats == null:
			return

		if can_dodge and state != STATE.DODGE and state != STATE.DASH_ATTACK:
			dodge_back()
			return

		# === TAKE DAMAGE ===
		var x_direction: int = sign(
			other_hitbox.global_position.direction_to(global_position).x
		)
		if x_direction == 0:
			x_direction = -1

		velocity.x = x_direction * knockback_force
		velocity.y = -knockback_up
		state = STATE.HIT

		stats.health -= other_hitbox.damage
		stats.health = max(stats.health, 0)

		if health_bar:
			health_bar.value = stats.health

		if stats.health <= 0:
			unlock_arena()
			queue_free()
	)
	

	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	match state:
		STATE.DASH_ATTACK:
			dash_to_player()
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
func start_intro() -> void:
	await get_tree().create_timer(intro_delay).timeout
	intro_done = true
	state = STATE.DASH_ATTACK


func dash_to_player() -> void:
	if not player:
		return

	state = STATE.DASH_ATTACK
	if not dash_audio:
		return

	dash_audio.pitch_scale = randf_range(0.85, 1.05) # heavier feel
	dash_audio.play()

	var dir: int = sign(player.global_position.x - global_position.x)
	if dir == 0:
		dir = 1
	anchor.scale.x = dir

	var dash_frames := 8
	var step := dash_distance / dash_frames

	for i in range(dash_frames):
		spawn_afterimage()
		global_position.x += dir * step
		await get_tree().create_timer(0.02).timeout

	state = STATE.ATTACK
	attack()


func _on_body_entered(body):
	print("Detected body:", body.name)

	if body is CharacterBody2D and body.is_in_group("player"):
		print("BOSS FIGHT START")
		lock_arena()
		arena_locked = true
		
		player = body
		state = STATE.INTRO
		start_intro()
		MusicManager.play_music(
			load("res://sounding/boss_attacking.mp3")
		)

func _on_body_exited(body):
	if body == player:
		player = null
		state = STATE.IDLE
		
	

func dodge_back() -> void:
	if not player or not can_dodge:
		return

	can_dodge = false
	state = STATE.DODGE

	var dir: int = sign(global_position.x - player.global_position.x)
	if dir == 0:
		dir = 1
	anchor.scale.x = dir

	var dash_frames := 6
	var step := dash_distance / dash_frames

	for i in range(dash_frames):
		spawn_afterimage()
		global_position.x += dir * step
		await get_tree().create_timer(0.02).timeout

	state = STATE.CHASE
	start_dodge_cooldown()


func start_dodge_cooldown() -> void:
	await get_tree().create_timer(dodge_cooldown).timeout
	can_dodge = true


func spawn_afterimage() -> void:
	var ghost: Node2D = anchor.duplicate()
	ghost.visible = true
	ghost.modulate = Color(1, 1, 1, 0.5)
	ghost.scale = anchor.scale
	ghost.z_index = anchor.z_index - 1

	get_tree().current_scene.add_child(ghost)
	ghost.global_position = anchor.global_position

	var tween := create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, 0.2)
	tween.tween_callback(ghost.queue_free)


func lock_arena():
	print("LOCK ARENA")

	for wall in get_tree().get_nodes_in_group("boss_arena_wall"):
		wall.visible = true
		for child in wall.get_children():
			if child is CollisionShape2D:
				child.set_deferred("disabled", false)
				
func unlock_arena():
	print("UNLOCK ARENA")

	for wall in get_tree().get_nodes_in_group("boss_arena_wall"):
		wall.visible = false
		for child in wall.get_children():
			if child is CollisionShape2D:
				child.set_deferred("disabled", true)
