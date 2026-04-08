extends Delivery
class_name ProjectileDelivery

@export var projectile_scene: PackedScene

func deliver(stats, effects):
	var projectile = projectile_scene.instantiate()
	projectile.damage = stats.damage
	projectile.effects = effects
	get_tree().current_scene.add_child(projectile)
