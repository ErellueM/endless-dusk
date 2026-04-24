extends Node2D

var damage: float = 0.0
var weapon_ref: Node2D = null
var target_pos: Vector2
var flight_time: float = 0.6 # Dauer des Flugs

@onready var sprite = $Sprite2D

func _ready():
	top_level = true
	_animate_flight()

func _animate_flight():
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 1. Die horizontale Bewegung zum Zielpunkt
	tween.tween_property(self, "global_position", target_pos, flight_time).set_trans(Tween.TRANS_LINEAR)
	
	# 2. Der Fake-Bogen (Sprite geht hoch und wieder runter)
	# Zuerst hoch...
	var arc_tween = create_tween()
	arc_tween.tween_property(sprite, "position:y", -60.0, flight_time / 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# ...dann runter zum Aufprall
	arc_tween.tween_property(sprite, "position:y", 0.0, flight_time / 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# 3. Rotation der Bombe während des Flugs
	tween.tween_property(sprite, "rotation_degrees", 360.0, flight_time)
	
	# Wenn die Zeit abgelaufen ist -> Explosion!
	tween.set_parallel(false)
	tween.tween_callback(_explode)

func _explode():
	sprite.hide()
	if has_node("GPUParticles2D"):
		$GPUParticles2D.emitting = true
	
	var camera = get_tree().get_first_node_in_group("camera")
	if camera and camera.has_method("shake"):
		camera.shake(0.2, 7) 

	# 1. Wir erstellen die Area
	var explosion_area = Area2D.new()
	explosion_area.collision_layer = 0
	explosion_area.collision_mask = 10 # Gegner + Props
	add_child(explosion_area)

	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 45.0 * (weapon_ref.get_actual_area() if weapon_ref else 1.0)
	shape.shape = circle
	explosion_area.add_child(shape)

	# --- DER FIX ---
	# Wir zwingen Godot, die Transformation (Position) der Area JETZT zu berechnen
	explosion_area.force_update_transform()
	
# Wir warten kurz auf den Physik-Frame
	await get_tree().physics_frame
	
	# Jetzt holen wir die Überlappungen
	var targets = explosion_area.get_overlapping_bodies() + explosion_area.get_overlapping_areas()
	
	# Sicherheitsnetz, falls die Area noch nicht schnell genug registriert wurde:
	if targets.is_empty():
		var query = PhysicsShapeQueryParameters2D.new()
		query.shape = circle
		query.transform = global_transform
		query.collision_mask = 10 # Checke Layer 2 und 4
		
		# --- DER FIX: WICHTIG FÜR SWARM ENEMIES (Area2D) ---
		query.collide_with_bodies = true
		query.collide_with_areas = true 
		# ---------------------------------------------------
		
		var results = get_world_2d().direct_space_state.intersect_shape(query)
		for res in results:
			if not targets.has(res.collider): # Verhindert, dass wir jemanden doppelt treffen
				targets.append(res.collider)

	# --- SCHADEN VERTEILEN ---
	for t in targets:
		if is_instance_valid(t) and (t.is_in_group("Enemygroup") or t.is_in_group("Props")):
			if t.has_method("take_damage"):
				var actual_dmg = t.take_damage(damage, true)
				if weapon_ref: 
					weapon_ref.add_damage_stat(actual_dmg)
				
				# LVL 5 Spezial: Burn Effekt
				if weapon_ref and weapon_ref.level >= 5:
					if t.has_method("add_status_effect"):
						t.add_status_effect(BurnEffect.new(2.0, 1.5, 0.3, weapon_ref))
	
	# Warten auf Partikel, dann löschen
	await get_tree().create_timer(0.5).timeout
	queue_free()
