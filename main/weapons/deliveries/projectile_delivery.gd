extends Node
class_name ProjectileDelivery

@export var projectile_scene: PackedScene

func deliver(stats, effects):
	var p = projectile_scene.instantiate()
	p.damage = stats.damage
	p.effects = effects
	get_tree().current_scene.add_child(p)
