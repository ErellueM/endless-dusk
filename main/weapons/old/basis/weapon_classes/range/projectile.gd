extends Area2D

var damage: float = 0.0
var velocity: Vector2 = Vector2.ZERO
var weapon_ref: Node2D = null

func _ready():
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(5.0).timeout
	queue_free()

func _physics_process(delta):
	position += velocity * delta
	rotation = velocity.angle() 

func _on_body_entered(body: Node2D):
	if body.is_in_group("Enemygroup"):
		var enemy_hp = 1000.0 # Fallback
		
		if "health_component" in body and body.health_component != null and "current_health" in body.health_component:
			enemy_hp = float(body.health_component.current_health)
		
		var actual_damage = min(damage, enemy_hp)
		
		if body.has_method("take_damage"):
			body.take_damage(damage)
			if weapon_ref and weapon_ref.has_method("add_damage_stat"):
				weapon_ref.add_damage_stat(actual_damage)
		
		
		if weapon_ref and body.has_method("add_status_effect"):
			if weapon_ref.get("applies_poison") == true:
				body.add_status_effect("knife_poison", {
					"color": Color(0.5, 1, 0.5),
					"duration": 5.0,
					"tick_damage": damage * 0.2,   
					"tick_rate": 1.0
				})
			
			# Bonus-Idee: Falls du mal eine Feuerwaffe baust:
			# if weapon_ref.get("applies_burn") == true:
			#     body.add_status_effect("fire", {...})

		queue_free()
