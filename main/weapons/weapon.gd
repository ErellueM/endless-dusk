extends Node
class_name Weapon

@export var stats: WeaponStats

@export var attack_component: Node
@export var delivery_component: Node
@export var effect_component: Node

var modifiers: Array = []

func attack():
	var final_stats = stats.get_modified(modifiers)
	attack_component.execute(final_stats, delivery_component, effect_component)
