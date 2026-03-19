extends Weapon

@export var flight_distance: float = 350.0
@export var flight_time: float = 0.8

func attack() -> bool:
	var target = get_nearest_enemy()
	var dir = Vector2.RIGHT
	
	if target:
		dir = global_position.direction_to(target.global_position)
	else:
		dir = Vector2.RIGHT.rotated(randf() * TAU)
		
	var boom = Area2D.new()
	boom.global_position = global_position
	boom.top_level = true
	boom.collision_layer = 0
	boom.collision_mask = 4294967295
	
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 6.0 * get_actual_area()
	shape.shape = circle
	boom.add_child(shape)
	
	var visual = _create_shuriken_visual(circle.radius)
	boom.add_child(visual)
	get_tree().current_scene.add_child(boom)
	
	var hit_enemies = []
	
	boom.body_entered.connect(func(body):
		if body.is_in_group("Enemygroup") and body.has_method("take_damage"):
			if not body in hit_enemies:
				var dmg = get_actual_damage()
				body.take_damage(dmg)
				add_damage_stat(dmg)
				hit_enemies.append(body)
	)
	
	var spin_tween = create_tween().bind_node(visual).set_loops()
	spin_tween.tween_property(visual, "rotation", TAU, 0.3).as_relative()
	
	var move_tween = create_tween()
	var target_pos = global_position + dir * (flight_distance * (get_actual_range() / base_range))
	
	move_tween.tween_property(boom, "global_position", target_pos, flight_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	move_tween.tween_callback(func():
		hit_enemies.clear()
		var return_tween = create_tween()
		return_tween.tween_method(func(t):
			if is_instance_valid(boom):
				if is_instance_valid(self):
					boom.global_position = target_pos.lerp(global_position, t)
				else:
					boom.queue_free()
		, 0.0, 1.0, flight_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		return_tween.tween_callback(boom.queue_free)
	)
	
	return true

func _create_shuriken_visual(rad: float) -> Node2D:
	var parent = Node2D.new()
	var poly = Polygon2D.new()
	poly.color = Color(0.2, 0.8, 1.0, 0.8)
	var pts = PackedVector2Array()
	
	for i in range(4):
		var angle = (i / 4.0) * TAU
		pts.append(Vector2(cos(angle), sin(angle)) * rad)
		var angle_inner = angle + (TAU / 8.0)
		pts.append(Vector2(cos(angle_inner), sin(angle_inner)) * (rad * 0.3))
		
	poly.polygon = pts
	parent.add_child(poly)
	return parent

func get_nearest_enemy() -> Node2D:
	var nearest = null
	var shortest_dist = get_actual_range()
	
	for enemy in get_tree().get_nodes_in_group("Enemygroup"):
		if not enemy or not enemy.is_inside_tree() or enemy.get("is_dead"): 
			continue
			
		var dist = global_position.distance_to(enemy.global_position)
		if dist < shortest_dist:
			shortest_dist = dist
			nearest = enemy
			
	return nearest

func get_upgrade_info(next_level: int) -> Dictionary:
	match next_level:
		2: return {"desc": "[color=green]+10 Base Damage[/color]\nSharper edges.", "rarity": "Common"}
		3: return {"desc": "[color=green]-0.5s Cooldown[/color]\nThrows faster.", "rarity": "Rare"}
		4: return {"desc": "[color=green]+20% Area Size[/color]\nLarger shuriken.", "rarity": "Common"}
		5: return {"desc": "[color=green]+30 Base Damage[/color]\nGhostly execution.", "rarity": "Legendary"}
	return {"desc": "MAX", "rarity": "Common"}

func _apply_stats_for_current_level():
	match level:
		2: base_damage += 10.0
		3: base_fire_rate -= 0.5
		4: base_area += 0.20
		5: base_damage += 30.0
