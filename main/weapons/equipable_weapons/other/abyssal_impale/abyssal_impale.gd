extends Weapon

@export var spike_count: int = 4
@export var erupt_delay: float = 0.5

func attack() -> bool:
	var vp_size = get_viewport_rect().size
	var dmg = get_actual_damage()
	
	for i in range(spike_count):
		var rx = randf_range(-vp_size.x * 0.45, vp_size.x * 0.45)
		var ry = randf_range(-vp_size.y * 0.45, vp_size.y * 0.45)
		var random_pos = global_position + Vector2(rx, ry)
		
		_spawn_crystal_spike(random_pos, dmg)
		
	return true

func _spawn_crystal_spike(spawn_pos: Vector2, dmg: float):
	var area = Area2D.new()
	area.global_position = spawn_pos
	area.top_level = true
	area.collision_layer = 0
	area.collision_mask = 4294967295
	
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 16.0 * get_actual_area() 
	shape.shape = circle
	area.add_child(shape)
	
	# Der dunkle Warn-Schatten auf dem Boden
	var shadow = Polygon2D.new()
	shadow.color = Color(0.05, 0.0, 0.1, 0.0)
	shadow.polygon = _create_ground_shadow(20.0)
	area.add_child(shadow)
	
	# Container für den Stachel
	var spike_visual = Node2D.new()
	spike_visual.scale.y = 0.0
	area.add_child(spike_visual)
	
	var base_color = Color(0.08, 0.02, 0.12, 1.0) 
	
	var main_spike = Polygon2D.new()
	main_spike.color = base_color
	main_spike.polygon = PackedVector2Array([
		Vector2(-6, 0), Vector2(6, 0), 
		Vector2(4, -30), Vector2(0, -75), 
		Vector2(-5, -45)
	])
	spike_visual.add_child(main_spike)
	
	var right_shard = Polygon2D.new()
	right_shard.color = Color(0.12, 0.05, 0.18, 1.0) 
	right_shard.polygon = PackedVector2Array([
		Vector2(3, 0), Vector2(10, 0), 
		Vector2(14, -15), Vector2(8, -35), 
		Vector2(5, -10)
	])
	spike_visual.add_child(right_shard)
	
	var left_shard = Polygon2D.new()
	left_shard.color = Color(0.05, 0.0, 0.08, 1.0) 
	left_shard.polygon = PackedVector2Array([
		Vector2(-4, 0), Vector2(-12, 0), 
		Vector2(-15, -12), Vector2(-9, -28), 
		Vector2(-6, -15)
	])
	spike_visual.add_child(left_shard)
	
	get_tree().current_scene.add_child(area)
	
	# --- DIE NEUE ANIMATION ---
	var tween = create_tween()
	
	# 1. Schatten fadet ein (Warnung)
	tween.tween_property(shadow, "color:a", 0.7, erupt_delay)
	
	# 2. Trefferberechnung & Hochschießen
	tween.tween_callback(func():
		for body in area.get_overlapping_bodies():
			if body.is_in_group("Enemygroup") and body.has_method("take_damage"):
				body.take_damage(dmg)
				add_damage_stat(dmg)
	)
	# TRANS_BACK lässt ihn wuchtig nach oben knallen
	tween.tween_property(spike_visual, "scale:y", 1.0, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# 3. Kurz stehen bleiben, damit man ihn sieht
	tween.tween_interval(0.25)
	
	# 4. Kristall rammt sich wieder in den Boden (scale:y auf 0)
	tween.tween_property(spike_visual, "scale:y", 0.0, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	# 5. Schatten schrumpft auf Null zusammen und Area löscht sich
	tween.tween_property(shadow, "scale", Vector2.ZERO, 0.15)
	tween.tween_callback(area.queue_free)

func _create_ground_shadow(radius: float) -> PackedVector2Array:
	var pts = PackedVector2Array()
	for j in range(16):
		var a = (j / 16.0) * TAU
		pts.append(Vector2(cos(a), sin(a)) * radius * Vector2(1.0, 0.4)) 
	return pts

func get_upgrade_info(next_level: int) -> Dictionary:
	match next_level:
		2: return {"desc": "[color=green]+2 Spikes[/color]\nMore eruptions.", "rarity": "Common"}
		3: return {"desc": "[color=green]+15 Base Damage[/color]\nLethal abyssal crystals.", "rarity": "Rare"}
		4: return {"desc": "[color=green]+20% Area Size[/color]\nWider eruption radius.", "rarity": "Common"}
		5: return {"desc": "[color=green]+4 Spikes[/color]\nGravelord's wrath.", "rarity": "Legendary"}
	return {"desc": "MAX", "rarity": "Common"}

func _apply_stats_for_current_level():
	match level:
		2: spike_count += 2
		3: base_damage += 15.0
		4: base_area += 0.20
		5: spike_count += 4
