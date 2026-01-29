#class_name Stats extends Resource
#
#@export var health: = 10 :
	#set(value):
		#health = value
		#if health <= 0: no_health.emit()
#
#signal no_health()
class_name Stats
extends Resource

@export var max_health := 10

@export var health := 10:
	set(value):
		health = clamp(value, 0, max_health)
		if health <= 0:
			no_health.emit()

signal no_health
