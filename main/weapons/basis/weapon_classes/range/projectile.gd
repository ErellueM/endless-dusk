extends Area2D

var damage: float = 0.0
var velocity: Vector2 = Vector2.ZERO
var weapon_ref: Node2D = null


func _ready():
	body_entered.connect(_on_hit)
	area_entered.connect(_on_hit)

	await get_tree().create_timer(10.0).timeout
	queue_free()


func _physics_process(delta):
	position += velocity * delta
	rotation = velocity.angle()


# Umbenannt in _on_hit, da "target" jetzt ein Body oder eine Area sein kann
func _on_hit(target: Node2D):
	if not target.is_in_group("player") and target.has_method("take_damage"):
		var actual_damage = target.take_damage(damage)

		if weapon_ref and weapon_ref.has_method("add_damage_stat"):
			weapon_ref.add_damage_stat(actual_damage)

		if weapon_ref and weapon_ref.get("applies_poison") == true:
			if target.has_method("add_status_effect"):
				var burn_tick_damage = damage * 0.2
				target.add_status_effect(PoisonEffect.new(3, burn_tick_damage, 0.5, weapon_ref))

		queue_free()
