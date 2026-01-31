extends Node2D
@onready var options_panel: Panel = $OptionsPanel

func _on_start_pressed() -> void:
	MusicManager.play_music(
		load("res://sounding/startOftheGame.mp3")
	)
	get_tree().change_scene_to_file("res://world.tscn")
func _on_options_pressed() -> void:
	options_panel.visible = !options_panel.visible


func _on_quit_pressed() -> void:
	get_tree().quit()
	
func _ready():
	MusicManager.play_music(
		load("res://sounding/firstExploring.mp3")
	)
	$OptionsPanel.visible = false
	$OptionsPanel/Buttom_manager2/MusicToggle.button_pressed = MusicManager.music_enabled

func _on_music_toggle_toggled(enabled: bool):
	MusicManager.set_music_enabled(enabled)


func _on_close_button_pressed() -> void:
	options_panel.visible = false
