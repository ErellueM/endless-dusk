extends GdUnitTestSuite

class WeaponDouble:
	extends Node2D
	var player_ref: Node = null

var character_weapons: CharacterWeapons
var test_weapon_scene: PackedScene

func before_test() -> void:
	character_weapons = CharacterWeapons.new()
	character_weapons.max_weapons = 3
	add_child(character_weapons)
	
	test_weapon_scene = PackedScene.new()
	var weapon := WeaponDouble.new()
	test_weapon_scene.pack(weapon)
	weapon.free()
	
	await get_tree().process_frame

func after_test() -> void:
	if character_weapons and is_instance_valid(character_weapons):
		character_weapons.queue_free()

func test_add_weapon_returns_true_on_success() -> void:
	var result := character_weapons.add_weapon(test_weapon_scene)
	assert_that(result).is_true()

func test_add_weapon_returns_false_when_inventory_full() -> void:
	character_weapons.add_weapon(test_weapon_scene)
	character_weapons.add_weapon(test_weapon_scene)
	character_weapons.add_weapon(test_weapon_scene)
	
	var result := character_weapons.add_weapon(test_weapon_scene)
	assert_that(result).is_false()

