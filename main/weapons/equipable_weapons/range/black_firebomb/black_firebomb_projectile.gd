extends Node2D

var damage: float = 0.0
var weapon_ref: Node2D = null
var target_pos: Vector2
var flight_time: float = 0.6 

@onready var sprite = $Sprite2D

func _ready():
	top_level = true
	_animate_flight()

func _animate_flight():
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(self, "global_position", target_pos, flight_time).set_trans(Tween.TRANS_LINEAR)
	
	var arc_tween = create_tween()
	arc_tween.tween_property(sprite, "position:y", -60.0, flight_time / 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	arc_tween.tween_property(sprite, "position:y", 0.0, flight_time / 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	tween.tween_property(sprite, "rotation_degrees", 360.0, flight_time)
	
	tween.set_parallel(false)
	tween.tween_callback(_explode)

func _explode():
	sprite.hide()
	if has_node("GPUParticles2D"):
		$GPUParticles2D.emitting = true
	
	var camera = get_tree().get_first_node_in_group("camera")
	if camera and camera.has_method("shake"):
		camera.shake(0.2, 7) 

	var explosion_area = Area2D.new()
	explosion_area.collision_layer = 0
	explosion_area.collision_mask = 10 
	add_child(explosion_area)

	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 45.0 * (weapon_ref.get_actual_area() if weapon_ref else 1.0)
	shape.shape = circle
	explosion_area.add_child(shape)

	explosion_area.force_update_transform()
	await get_tree().physics_frame
	
	var targets = explosion_area.get_overlapping_bodies() + explosion_area.get_overlapping_areas()
	
	if targets.is_empty():
		var query = PhysicsShapeQueryParameters2D.new()
		query.shape = circle
		query.transform = global_transform
		query.collision_mask = 10
		query.collide_with_bodies = true
		query.collide_with_areas = true 
		
		var results = get_world_2d().direct_space_state.intersect_shape(query)
		for res in results:
			if not targets.has(res.collider):
				targets.append(res.collider)

	for t in targets:
		if is_instance_valid(t) and (t.is_in_group("Enemygroup") or t.is_in_group("Props")):
			if t.has_method("take_damage"):
				var actual_dmg = t.take_damage(damage, true)
				if weapon_ref: 
					weapon_ref.add_damage_stat(actual_dmg)
				
				if weapon_ref and weapon_ref.level >= 5:
					if t.has_method("add_status_effect"):
						# HIER IST DAS SCALING: Tickt für 30% des Bombenschadens!
						var burn_tick_damage = damage * 0.3
						t.add_status_effect(BurnEffect.new(3.0, burn_tick_damage,1.0 , weapon_ref))
	
	await get_tree().create_timer(0.5).timeout
	queue_free()
