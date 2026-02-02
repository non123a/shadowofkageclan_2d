#extends TextureRect
#
#@onready var respawn_button: TextureButton = $Panel/RespawnButton
#@onready var quit_button: TextureButton = $Panel/QuitButton
#
#
#func _ready():
	#visible = false
	#process_mode = Node.PROCESS_MODE_ALWAYS
#
	#respawn_button.pressed.connect(_on_respawn_pressed)
	#quit_button.pressed.connect(_on_quit_pressed)
#
#
#func show_panel():
	#print("🔥 SHOW DEATH PANEL CALLED")
	##print("Paused:", get_tree().paused)
	#print("Music playing:", MusicManager.playing)
	## FORCE stop gameplay music
	#MusicManager.stop_music(false)
#
	## 🔴 PLAY death music
	#MusicManager.play_music(
		#load("res://sounding/die.mp3"),
		#false
	#)
#
	#visible = true
#
	## 🔴 Pause AFTER audio starts
	#await get_tree().process_frame
	#get_tree().paused = true
#
#
#func hide_panel():
	#get_tree().paused = false
	#visible = false
#
#
#func _on_respawn_pressed():
	#get_tree().paused = false
	#hide_panel()
	#get_tree().reload_current_scene()
	#
#
#
#func _on_quit_pressed():
	#hide_panel()
	#get_tree().change_scene_to_file("res://main_menu.tscn")


extends TextureRect

@onready var respawn_button: TextureButton = $Panel/RespawnButton
@onready var quit_button: TextureButton = $Panel/QuitButton

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	respawn_button.pressed.connect(_on_respawn_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func show_panel():
	visible = true

func hide_panel():
	visible = false

func _on_respawn_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
