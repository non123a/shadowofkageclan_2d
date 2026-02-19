extends Area2D

#func _on_EndZone_body_entered(body):
	#if body.name == "Player":
		#get_tree().change_scene_to_file("res://scenes/EndingScene.tscn")


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		MusicManager.stop_music(true)
		get_tree().change_scene_to_file("res://EndingScene.tscn")
