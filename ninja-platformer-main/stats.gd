class_name Stats
extends Resource

signal health_changed(current: int, max: int)
signal no_health

@export var max_health := 10

@export var health := 10:
	set(value):
		health = clamp(value, 0, max_health)
		health_changed.emit(health, max_health)

		if health <= 0:
			no_health.emit()
