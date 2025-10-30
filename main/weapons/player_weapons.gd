extends CharacterWeapons


func _process(delta: float) -> void:
	var mouse_pos : Vector2 = get_global_mouse_position()
	var mouse_dir : Vector2 = global_position.direction_to(mouse_pos)
	
	
	if weapon:
		weapon.set_aim_angle(mouse_dir)
