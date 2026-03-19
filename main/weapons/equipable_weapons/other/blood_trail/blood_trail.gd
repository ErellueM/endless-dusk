extends Weapon

var last_drop_pos: Vector2 = Vector2.INF

func attack() -> bool:
	if global_position.distance_to(last_drop_pos) < 40.0:
		return false
		
	last_drop_pos = global_position
	
	var puddle = Area2D.new()
	puddle.global_position = global_position
	puddle.top_level = true
	puddle.collision_layer = 0
	puddle.collision_mask = 4294967295
	
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 25.0 * get_actual_area()
	shape.shape = circle
	puddle.add_child(shape)
	
	var dark_blood = Polygon2D.new()
	dark_blood.color = Color(0.3, 0.0, 0.0, 0.8)
	dark_blood.polygon = _create_splat(circle.radius)
	puddle.add_child(dark_blood)
	
	var bright_blood = Polygon2D.new()
	bright_blood.color = Color(0.7, 0.0, 0.1, 0.9)
	bright_blood.polygon = _create_splat(circle.radius * 0.6)
	puddle.add_child(bright_blood)
	
	get_tree().current_scene.add_child(puddle)
	
	var dmg_timer = Timer.new()
	dmg_timer.wait_time = 0.5
	dmg_timer.autostart = true
	puddle.add_child(dmg_timer)
	
	dmg_timer.timeout.connect(func():
		if is_instance_valid(puddle):
			var dmg = get_actual_damage()
			for body in puddle.get_overlapping_bodies():
				if body.is_in_group("Enemygroup") and body.has_method("take_damage"):
					body.take_damage(dmg)
					add_damage_stat(dmg)
	)
	
	var tween = create_tween()
	tween.tween_property(dark_blood, "color:a", 0.0, 4.0)
	tween.parallel().tween_property(bright_blood, "color:a", 0.0, 4.0)
	tween.tween_callback(puddle.queue_free)
	
	return true

func _create_splat(base_rad: float) -> PackedVector2Array:
	var pts = PackedVector2Array()
	var points_count = 10
	for j in range(points_count):
		var a = (j / float(points_count)) * TAU
		var r = base_rad * randf_range(0.6, 1.2)
		pts.append(Vector2(cos(a), sin(a)) * r)
	return pts

func get_upgrade_info(next_level: int) -> Dictionary:
	match next_level:
		2: return {"desc": "[color=green]+10 Base Damage[/color]\nThicker blood.", "rarity": "Common"}
		3: return {"desc": "[color=green]+40% Area Size[/color]\nHuge puddles.", "rarity": "Rare"}
		4: return {"desc": "[color=green]-0.3s Drop Cooldown[/color]\nLeaves a solid trail.", "rarity": "Common"}
		5: return {"desc": "[color=green]+20 Base Damage[/color]\nLethal curse.", "rarity": "Legendary"}
	return {"desc": "MAX", "rarity": "Common"}

func _apply_stats_for_current_level():
	match level:
		2: base_damage += 10.0
		3: base_area += 0.40
		4: base_fire_rate -= 0.3
		5: base_damage += 20.0
