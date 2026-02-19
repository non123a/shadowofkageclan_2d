extends Node2D

@onready var label = $ScrollContainer/Label

#func _ready():
	#MusicManager.stop_music(true)
func _process(delta):
	label.position.y -= 8 * delta
