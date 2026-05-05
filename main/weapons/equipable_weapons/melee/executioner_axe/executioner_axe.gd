extends Weapon
class_name ExecutionerAxe

@export_group("Axe Settings")
@export var axe_sprite: Texture2D
@export var sprite_rotation_offset: float = 135.0 

# DER ULTIMATIVE KLINGEN-FIX: Haken setzen, wenn die Klinge falsch rum ist!
@export var inverse_blade: bool = false 

@export var chop_length: float = 80.0
@export var chop_width: float = 30.0
@export var crater_offset: Vector2 = Vector2(0, 0)
@export var windup_time: float = 0.3 
@export var slam_time: float = 0.1   

func attack() -> bool:
	var target = _get_closest_enemy()
	if not target: return false

	var target_dir = global_position.direction_to(target.global_position)
	var base_angle = target_dir.angle()
	
	_perform_slam(base_angle)
	
	if level >= 8:
		_perform_slam(base_angle + PI) 

	return true

func _perform_slam(base_angle: float):
	var dmg = get_actual_damage()
	var area_mult = get_actual_area()
	
	var actual_length = chop_length * area_mult
	var actual_width = chop_width * area_mult

	var pivot = Node2D.new()
	add_child(pivot)
	pivot.global_rotation = base_angle
	pivot.z_index = z_index + 1

	var area = Area2D.new()
	area.collision_layer = 0
	area.collision_mask = 10
	pivot.add_child(area)

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(actual_length, actual_width)
	shape.shape = rect
	shape.position = Vector2(actual_length / 2.0, 0)
	area.add_child(shape)

	var visual_pivot = Node2D.new()
	visual_pivot.position = Vector2.ZERO 
	visual_pivot.rotation_degrees = -100.0 
	area.add_child(visual_pivot)

	var sprite: Sprite2D = null
	if axe_sprite:
		sprite = Sprite2D.new()
		sprite.texture = axe_sprite
		sprite.position = Vector2(actual_length / 2.0, 0) 
		sprite.rotation_degrees = sprite_rotation_offset
		
		# Versteckt starten
		sprite.scale = Vector2(area_mult, 0.0) 
		sprite.modulate.a = 0.0
		sprite.visible = false 
		visual_pivot.add_child(sprite)

	var tween = create_tween()
	
	if sprite:
		tween.tween_callback(sprite.show) 
	
	# --- DER MAGISCHE KLINGEN-FIX ---
	var target_scale_y = area_mult
	if inverse_blade:
		target_scale_y = -area_mult # Spiegelt das Bild direkt beim Aufklappen!

	tween.set_parallel(true)
	tween.tween_property(visual_pivot, "rotation_degrees", -130.0, windup_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if sprite:
		# Hier klappt sich die Axt in die richtige (oder gespiegelte) Richtung auf
		tween.tween_property(sprite, "scale:y", target_scale_y, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(sprite, "modulate:a", 1.0, 0.1)
	tween.set_parallel(false) 
	
	tween.tween_property(visual_pivot, "rotation_degrees", 0.0, slam_time).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	
	tween.tween_callback(
		func():
			var camera = get_tree().get_first_node_in_group("camera")
			if camera and camera.has_method("shake"):
				camera.shake(0.25, 7)
				
			area.force_update_transform()
			var targets = area.get_overlapping_bodies() + area.get_overlapping_areas()
			
			for t in targets:
				if is_instance_valid(t) and (t.is_in_group("Enemygroup") or t.is_in_group("Props")):
					if t.has_method("take_damage"):
						var actual_dmg = t.take_damage(dmg, true)
						add_damage_stat(actual_dmg)
						
						if level >= 5 and t.has_method("add_status_effect"):
							t.add_status_effect(VulnerableEffect.new(3.0, 1.5))
			
			# --- NEU: Rein visueller Riss bei 3/4 der Klinge ---
			# Vector2(actual_length * 0.75, 0) ist exakt 3/4 nach vorne und mittig auf der Breite!
			# --- NEU: Mit Feintuning-Offset ---
			# Wir nehmen die 3/4 Position und addieren deinen manuellen Offset dazu
			var local_impact = Vector2(actual_length * 0.2, 0) + crater_offset
			var impact_pos = pivot.global_position + local_impact.rotated(base_angle)
			
			_spawn_visual_crater(impact_pos)
	)
	
	tween.tween_interval(0.2)
	if sprite:
		tween.set_parallel(true)
		tween.tween_property(sprite, "scale:y", 0.0, 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_property(sprite, "modulate:a", 0.0, 0.15)
		tween.set_parallel(false)
		
	tween.tween_callback(pivot.queue_free)

# --- REIN VISUELLER KRATER (Kein Schaden, nur Optik) ---
func _spawn_visual_crater(spawn_pos: Vector2):
	var crater = Node2D.new()
	crater.global_position = spawn_pos
	crater.z_index = 1 # Bleibt unter dem Spieler/Gegnern liegen
	
	# 3 bis 4 kleine Risse
	var num_cracks = randi_range(3, 4) 
	
	var taper_curve = Curve.new()
	taper_curve.add_point(Vector2(0.0, 1.0))
	taper_curve.add_point(Vector2(1.0, 0.0))
	
	for i in range(num_cracks):
		var line = Line2D.new()
		line.default_color = Color(0.15, 0.15, 0.15, 0.8) # Dunkles Grau-Braun
		line.width = randf_range(2.0, 4.0)
		line.width_curve = taper_curve
		
		var points = PackedVector2Array()
		points.append(Vector2.ZERO)
		
		var current_pos = Vector2.ZERO
		var angle = randf_range(0, TAU)
		var segments = randi_range(1, 3)
		
		for j in range(segments):
			# Sehr kurze Risse (ca. 5 bis 10 Pixel lang pro Knick)
			var step_length = randf_range(5.0, 10.0) 
			angle += randf_range(-0.5, 0.5) 
			current_pos += Vector2.RIGHT.rotated(angle) * step_length
			points.append(current_pos)
			
		line.points = points
		crater.add_child(line)

	get_tree().current_scene.add_child(crater)
	
	# Nach 2 Sekunden ausblenden und löschen
	var fade_tween = create_tween()
	fade_tween.tween_interval(2.0) # 2 Sekunden liegen bleiben
	fade_tween.tween_property(crater, "modulate:a", 0.0, 0.5) # In 0.5s unsichtbar werden
	fade_tween.tween_callback(crater.queue_free)

func _get_closest_enemy() -> Node2D:
	# ... (Bleibt exakt gleich wie vorher)
	var targets = get_tree().get_nodes_in_group("Enemygroup") + get_tree().get_nodes_in_group("Props")
	var closest = null
	var min_dist = get_actual_range()
	for t in targets:
		if is_instance_valid(t) and t.visible and not t.get("is_dead"):
			var dist = global_position.distance_to(t.global_position)
			if dist < min_dist:
				min_dist = dist
				closest = t
	return closest

# --- UPGRADES EXECUTIONER AXE ---
func get_upgrade_info(next_level: int) -> Dictionary:
	match next_level:
		2: return {"desc": "[color=green]+10 Base Damage[/color]\nHeavier swings.", "rarity": "Common"}
		3: return {"desc": "[color=green]+20% Chop Width[/color]\nCleave through more enemies.", "rarity": "Uncommon"}
		4: return {"desc": "[color=green]-15% Cooldown[/color]\nFaster strikes.", "rarity": "Rare"}
		5: return {"desc": "[color=purple]Armor Breaker[/color]\nEnemies hit become Vulnerable (+50% dmg taken).", "rarity": "Epic"}
		6: return {"desc": "[color=green]+15 Base Damage[/color]\nRuthless power.", "rarity": "Uncommon"}
		7: return {"desc": "[color=green]+25% Area[/color]\nMassive axes.", "rarity": "Rare"}
		8: return {"desc": "[color=orange]Twin Execution[/color]\nStrikes forward and backward simultaneously!", "rarity": "Legendary"}
	return {"desc": "MAX", "rarity": "Common"}

func _apply_stats_for_current_level():
	match level:
		2: base_damage += 10.0 # Von 15 auf 25 (tötet selbst Tank-Slimes fast sofort)
		3: base_area += 0.20
		4: base_fire_rate *= 0.85
		5: pass # Der Vulnerable Effect
		6: base_damage += 15.0 # Von 25 auf 40
		7: base_area += 0.25
		8: pass # Doppelschlag in attack()
