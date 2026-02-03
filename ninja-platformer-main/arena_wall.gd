#extends StaticBody2D
#
#func lock():
	#visible = true
	#set_deferred("collision_layer", 2)
	#set_deferred("collision_mask", 2)
#
#func unlock():
	#visible = false
	#set_deferred("collision_layer", 0)
	#set_deferred("collision_mask", 0)
#
#func _ready():
	#visible = false
	#for child in get_children():
		#if child is CollisionShape2D:
			#child.disabled = true


extends StaticBody2D

func _ready():
	print("[WALL]", name, "READY")
	print("  layer:", collision_layer, " mask:", collision_mask)

	for child in get_children():
		if child is CollisionShape2D:
			print(
				"  shape:", child.name,
				" disabled =", child.disabled
			)
