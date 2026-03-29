extends Node
class_name HitboxDelivery

@export var hitbox_scene: PackedScene

func deliver(stats, effects):
	var hitbox = hitbox_scene.instantiate()
	hitbox.damage = stats.damage
	hitbox.scale *= stats.area
	hitbox.effects = effects
	add_child(hitbox)
