extends Node2D
class_name CharacterWeapons

@export var starting_weapons: Array[PackedScene]
@export var max_weapons: int = 6

func _ready() -> void:
	for weapon in starting_weapons:
		if weapon:
			add_weapon(weapon)

func add_weapon(weapon_scene: PackedScene) -> bool:

	if get_child_count() >= max_weapons:
		print("Inventar voll! Maximale Anzahl an Waffen erreicht.")
		return false
		
	var new_weapon = weapon_scene.instantiate()
	add_child(new_weapon) 
	if "player_ref" in new_weapon:
		new_weapon.player_ref = get_parent()
		
	return true
