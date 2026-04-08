extends StatCollection
class_name WeaponStats

@export var damage := 10.0
@export var attack_speed := 1.0
@export var area := 1.0
@export var tick_rate := 0.5
@export var splash_area := 0.0
@export var splash_damage_factor := 0.5
@export var range = 100

func get_modified(modifiers: Array) -> WeaponStats:
	var result = duplicate()

	for mod in modifiers:
		mod.apply(result)

	return result
