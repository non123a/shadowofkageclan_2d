extends CanvasLayer

@onready var respawn_button: Button = $Panel/RespawnButton
@onready var quit_button: Button = $Panel/QuitButton

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	respawn_button.pressed.connect(_on_respawn_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func show_panel():
	visible = true
	get_tree().paused = true

func hide_panel():
	visible = false
	get_tree().paused = false

func _on_respawn_pressed():
	hide_panel()
	get_tree().reload_current_scene()

func _on_quit_pressed():
	hide_panel()
	get_tree().change_scene_to_file("res://main_menu.tscn")
