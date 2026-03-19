extends Weapon

@export_group("Orbital Strike Stats")
@export var strike_count: int = 1
@export var strike_radius: float = 60.0

func attack() -> bool:
	var enemies = get_tree().get_nodes_in_group("Enemygroup")
	var valid_enemies = []
	
	var viewport_rect = get_viewport_rect()
	
	for e in enemies:
		if not e.get("is_dead"):
			var screen_pos = e.get_global_transform_with_canvas().origin
			if viewport_rect.has_point(screen_pos):
				valid_enemies.append(e)
				
	if valid_enemies.size() == 0:
		return false
		
	var dmg = get_actual_damage()
	
	for i in range(strike_count):
		if valid_enemies.size() == 0:
			break
			
		var target = valid_enemies.pick_random()
		valid_enemies.erase(target) 
		
		_spawn_laser_visual(target.global_position)
		
		for e in get_tree().get_nodes_in_group("Enemygroup"):
			if not e.get("is_dead"):
				if e.global_position.distance_to(target.global_position) <= strike_radius:
					if e.has_method("take_damage"):
						e.take_damage(dmg)
						add_damage_stat(dmg)
						
	return true

func _spawn_laser_visual(pos: Vector2):
	var laser = Line2D.new()
	laser.top_level = true
	
	laser.add_point(pos + Vector2(0, -1500))
	laser.add_point(pos)
	
	laser.width = 20.0
	laser.default_color = Color(1.0, 0.9, 0.4, 1.0) 
	laser.begin_cap_mode = Line2D.LINE_CAP_ROUND
	laser.end_cap_mode = Line2D.LINE_CAP_ROUND

	get_tree().current_scene.add_child(laser)

	var tween = create_tween()
	tween.tween_property(laser, "width", 0.0, 0.3).set_trans(Tween.TRANS_EXPO)
	tween.tween_callback(laser.queue_free)


func get_upgrade_info(next_level: int) -> Dictionary:
	match next_level:
		2: return {"desc": "[color=green]+1 Pillar of Light[/color]\nThe gods judge another soul.", "rarity": "Common"}
		3: return {"desc": "[color=green]+20 Blast Radius[/color]\nBlinding holy explosion.", "rarity": "Rare"}
		4: return {"desc": "[color=green]+20 Holy Damage[/color]\nPurge the darkness.", "rarity": "Common"}
		5: return {"desc": "[color=green]+2 Pillars of Light[/color]\nWrath of the Heavens!", "rarity": "Legendary"}
	return {"desc": "MAX", "rarity": "Common"}

func _apply_stats_for_current_level():
	match level:
		2: strike_count += 1
		3: strike_radius += 20.0
		4: base_damage += 20.0
		5: strike_count += 2
