extends Node2D
class_name CharacterWeapons

var max_weapons: int = 6

func add_weapon(weapon_scene: PackedScene) -> bool:
	if not weapon_scene:
		return false
		
	if get_child_count() >= max_weapons:
		print("Inventar voll! Maximale Anzahl an Waffen erreicht.")
		return false
		
	var new_weapon = weapon_scene.instantiate()
	add_child(new_weapon) 
	if "player_ref" in new_weapon:
		new_weapon.player_ref = get_parent()
		
	return true
