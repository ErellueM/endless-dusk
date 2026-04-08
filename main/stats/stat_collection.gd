extends Resource
class_name StatCollection

func get_modified(modifiers: Array) -> WeaponStats:
	var result = duplicate()

	for mod in modifiers:
		mod.apply(result)

	return result
