extends Weapon
class_name BaseMeleeWeapon

@export_group("Melee Settings")
@export var weapon_sprite: Texture2D
@export var sprite_rotation_offset: float = 135.0 
@export var swing_arc_degrees: float = 180.0
@export var swing_duration: float = 0.15

@export_group("Hitbox & Size")
@export var reach: float = 40.0                  # Wie lang die Klinge ist
@export var hitbox_width: float = 20.0           # Wie dick/breit die Klinge ist
@export var distance_from_center: float = 15.0   # Wie weit der Griff von der Spieler-Mitte weg ist

func attack() -> bool:
	var target = _get_closest_enemy()
	if not target: return false

	# Globaler Winkel zum Gegner
	var target_dir = global_position.direction_to(target.global_position)
	_perform_swing(target_dir.angle())
	return true

func _perform_swing(base_angle: float):
	var dmg = get_actual_damage()
	var area_mult = get_actual_area() 
	
	var actual_reach = reach * area_mult
	var actual_width = hitbox_width * area_mult
	var actual_distance = distance_from_center * area_mult

	var half_arc = deg_to_rad(swing_arc_degrees) / 2.0
	var start_angle = base_angle - half_arc
	var end_angle = base_angle + half_arc

	var pivot = Node2D.new()
	add_child(pivot) 
	pivot.position = Vector2.ZERO 
	pivot.z_index = z_index + 1
	# Wir setzen es SOFORT auf den Startwinkel, damit es nicht springt
	pivot.global_rotation = start_angle

	var area = Area2D.new()
	area.collision_layer = 0
	area.collision_mask = 10
	pivot.add_child(area)

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(actual_reach, actual_width)
	shape.shape = rect
	
	var center_of_blade = actual_distance + (actual_reach / 2.0)
	shape.position = Vector2(center_of_blade, 0)
	area.add_child(shape)

	# --- SPRITE SETUP ---
	var sprite: Sprite2D = null
	if weapon_sprite:
		sprite = Sprite2D.new()
		sprite.texture = weapon_sprite
		sprite.position = Vector2(center_of_blade, 0) 
		
		# WICHTIG: Das Schwert startet auf der Y-Achse mit 0 (es ist plattgedrückt!) und ist unsichtbar
		sprite.scale = Vector2(area_mult, 0.0) 
		sprite.modulate.a = 0.0
		
		sprite.rotation_degrees = sprite_rotation_offset
		area.add_child(sprite)

	var hit_targets = []
	var swing_logic = func(current_angle: float):
		if not is_instance_valid(pivot): return 
		pivot.global_rotation = current_angle
		
		var overlapping = area.get_overlapping_bodies() + area.get_overlapping_areas()
		for t in overlapping:
			if t not in hit_targets and (t.is_in_group("Enemygroup") or t.is_in_group("Props")):
				hit_targets.append(t)
				if t.has_method("take_damage"):
					var true_dmg = t.take_damage(dmg, true)
					add_damage_stat(true_dmg)

	# --- ANIMATIONS MAGIE ---
	var tween = create_tween()
	# set_parallel(true) zwingt Godot dazu, alle folgenden Animationen GLEICHZEITIG abzuspielen!
	tween.set_parallel(true) 
	
	# 1. Die Schwung-Bewegung an sich
	tween.tween_method(swing_logic, start_angle, end_angle, swing_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	if sprite:
		# Wir nutzen jeweils 30% der Schwungzeit für das "Ziehen" und das "Einstecken"
		var anim_time = swing_duration * 0.3
		var hide_delay = swing_duration - anim_time

		# 2. SCHWERT ZIEHEN (Breite auf Normalgröße ploppen und sichtbar machen)
		# TRANS_BACK lässt es kurz minimal zu groß werden (Gummiband-Effekt)
		tween.tween_property(sprite, "scale:y", area_mult, anim_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(sprite, "modulate:a", 1.0, anim_time)

		# 3. SCHWERT EINSTECKEN (Breite wieder auf 0 quetschen und unsichtbar machen)
		# Mit set_delay wartet diese Animation, bis der Schwung fast vorbei ist!
		tween.tween_property(sprite, "scale:y", 0.0, anim_time).set_delay(hide_delay).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_property(sprite, "modulate:a", 0.0, anim_time).set_delay(hide_delay)

	# Am Ende schalten wir Parallel wieder ab, damit das Löschen wirklich erst ganz zum Schluss passiert
	tween.set_parallel(false)
	tween.tween_callback(pivot.queue_free)

func _get_closest_enemy() -> Node2D:
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
