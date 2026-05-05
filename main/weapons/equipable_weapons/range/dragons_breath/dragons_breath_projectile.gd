extends Area2D

var damage: float = 0.0
var velocity: Vector2 = Vector2.ZERO
var weapon_ref: Node2D = null

var hit_targets: Array = [] 

func _ready():
	top_level = true 
	
	body_entered.connect(_on_hit)
	area_entered.connect(_on_hit)

	# Schrotflinten-Kugeln fliegen nicht unendlich weit!
	# Sie lösen sich nach kurzer Zeit auf (das definiert die Reichweite).
	var fade_tween = create_tween()
	fade_tween.tween_interval(0.3) # Fliegt für 0.3 Sekunden mit voller Kraft
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.1) # Blendet sanft aus
	fade_tween.tween_callback(queue_free) # Löscht sich selbst

func _physics_process(delta):
	position += velocity * delta
	rotation = velocity.angle()

func _on_hit(target: Node2D):
	var unique_id = str(target.get_instance_id()) + "_" + str(target.get("spawn_generation"))

	if unique_id in hit_targets:
		return 
		
	if (target.is_in_group("Enemygroup") or target.is_in_group("Props")) and target.has_method("take_damage"):
		hit_targets.append(unique_id)
		
		var actual_damage = target.take_damage(damage, true)

		if weapon_ref and is_instance_valid(weapon_ref):
			weapon_ref.add_damage_stat(actual_damage)
			
		# Optional: Auch hier könntest du den Burn-Effekt drauflegen!
		if target.has_method("add_status_effect"):
			var burn_tick_damage = damage * 0.3
			target.add_status_effect(BurnEffect.new(2.0, burn_tick_damage, 1.0, weapon_ref))
