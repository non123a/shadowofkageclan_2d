extends AudioStreamPlayer2D

func _ready():
	playing = true
	finished.connect(_on_finished)

func _on_finished():
	play()
