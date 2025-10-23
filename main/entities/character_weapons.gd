extends Node2D
class_name CharacterWeapons

@export var weapon_to_equip : PackedScene
var weapon : Weapon

func _ready() -> void:
	if weapon_to_equip:
		equip_weapon(weapon_to_equip)

func equip_weapon(weapon_scene : PackedScene):
	weapon = weapon_scene.instantiate()
	add_child(weapon)
	weapon.global_position= global_position
