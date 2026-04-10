extends Area2D

var damage: float = 0.0
var velocity: Vector2 = Vector2.ZERO
var weapon_ref: Node2D = null


func _ready():
	# FIX: Das Projektil reagiert jetzt auf dicke Bosse (Bodies) UND kleine Slimes (Areas)!
	body_entered.connect(_on_hit)
	area_entered.connect(_on_hit)

	await get_tree().create_timer(5.0).timeout
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
			var manager = target.get_node_or_null("StatusManager")
			if manager:
				manager.add_effect(PoisonEffect.new(3, 3, 0.5))

		queue_free()
