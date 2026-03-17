extends Node2D
class_name CharacterWeapons

@export var starting_weapon: PackedScene

func _ready() -> void:
	if starting_weapon:
		add_weapon(starting_weapon)

func add_weapon(weapon_scene: PackedScene):
	var new_weapon = weapon_scene.instantiate()
	add_child(new_weapon)
	if "player_ref" in new_weapon:
		new_weapon.player_ref = get_parent()
