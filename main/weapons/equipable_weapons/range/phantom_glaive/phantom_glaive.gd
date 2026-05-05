extends Weapon

@export var flight_distance: float = 350.0
@export var flight_time: float = 0.8
var projectile_count: int = 1 # NEU!

func attack() -> bool:
	var target = get_nearest_enemy()
	var base_dir = Vector2.RIGHT

	if target:
		base_dir = global_position.direction_to(target.global_position)
	else:
		base_dir = Vector2.RIGHT.rotated(randf() * TAU)

	# NEU: Verteilt die Bumerangs fächerförmig, wenn es mehr als 1 gibt
	var spread_angle = deg_to_rad(30.0) # 30 Grad Abstand zwischen den Gleven
	var start_angle = base_dir.angle() - (spread_angle * (projectile_count - 1) / 2.0)

	for i in range(projectile_count):
		var current_angle = start_angle + (i * spread_angle)
		var dir = Vector2(cos(current_angle), sin(current_angle))
		
		# --- Ab hier bleibt dein Code fast gleich, nur in der Schleife eingerückt! ---
		var boom = Area2D.new()
		boom.global_position = global_position
		boom.top_level = true

		boom.collision_layer = 0
		boom.collision_mask = 0
		boom.set_collision_mask_value(2, true)  # Layer 2 = Enemies
		boom.set_collision_mask_value(4, true)  # Layer 4 = Props/Fässer

		var shape = CollisionShape2D.new()
		var circle = CircleShape2D.new()
		circle.radius = 6.0 * get_actual_area()
		shape.shape = circle
		boom.add_child(shape)

		var visual = _create_shuriken_visual(circle.radius)
		boom.add_child(visual)
		get_tree().current_scene.add_child(boom)

		var hit_enemies = []

		var hit_logic = func(hit_target: Node2D):
			if not hit_target in hit_enemies and hit_target.has_method("take_damage"):
				hit_enemies.append(hit_target)
				var dmg = get_actual_damage()
				var true_dmg = hit_target.take_damage(dmg)
				add_damage_stat(true_dmg)

		boom.body_entered.connect(hit_logic)
		boom.area_entered.connect(hit_logic)

		var spin_tween = create_tween().bind_node(visual).set_loops()
		spin_tween.tween_property(visual, "rotation", TAU, 0.3).as_relative()

		var move_tween = create_tween()
		var target_pos = global_position + dir * (flight_distance * (get_actual_range() / base_range))

		(
			move_tween
			. tween_property(boom, "global_position", target_pos, flight_time)
			. set_trans(Tween.TRANS_SINE)
			. set_ease(Tween.EASE_OUT)
		)
		move_tween.tween_callback(
			func():
				hit_enemies.clear()  # Auf dem Rückweg nochmal treffen!
				var return_tween = create_tween()
				(
					return_tween
					. tween_method(
						func(t):
							if is_instance_valid(boom):
								if is_instance_valid(self):
									boom.global_position = target_pos.lerp(global_position, t)
								else:
									boom.queue_free(),
						0.0,
						1.0,
						flight_time
					)
					. set_trans(Tween.TRANS_SINE)
					. set_ease(Tween.EASE_IN)
				)
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

	for enemy in (
		get_tree().get_nodes_in_group("Enemygroup") + get_tree().get_nodes_in_group("Props")
	):
		if not enemy or not enemy.is_inside_tree() or enemy.get("is_dead"):
			continue

		var dist = global_position.distance_to(enemy.global_position)
		if dist < shortest_dist:
			shortest_dist = dist
			nearest = enemy

	return nearest


func get_upgrade_info(next_level: int) -> Dictionary:
	match next_level:
		2: return {"desc": "[color=green]+8 Base Damage[/color]\nSharper edges.", "rarity": "Common"}
		3: return {"desc": "[color=green]-0.3s Cooldown[/color]\n[color=green]+15% Area[/color]", "rarity": "Uncommon"}
		4: return {"desc": "[color=green]+10 Base Damage[/color]\nLethal force.", "rarity": "Rare"}
		5: return {"desc": "[color=cyan]Triple Phantom[/color]\n[color=green]Throws 3 Glaives at once![/color]", "rarity": "Legendary"}
	return {"desc": "MAX", "rarity": "Common"}

func _apply_stats_for_current_level():
	match level:
		2: base_damage += 8.0
		3: 
			base_fire_rate -= 0.3
			base_area += 0.15
		4: base_damage += 10.0
		5: projectile_count = 3 # Der ultimative Boost!
