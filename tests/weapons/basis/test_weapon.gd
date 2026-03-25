extends GdUnitTestSuite

class PlayerDouble:
	extends Node2D
	var might: float = 1.0
	var cooldown_mult: float = 1.0
	var area: float = 1.0

var weapon: Weapon
var player: PlayerDouble

func before_test() -> void:
	weapon = Weapon.new()
	player = PlayerDouble.new()
	add_child(weapon)
	add_child(player)
	await get_tree().process_frame

func after_test() -> void:
	if weapon and is_instance_valid(weapon):
		weapon.queue_free()
	if player and is_instance_valid(player):
		player.queue_free()

func test_get_actual_damage_returns_base_damage_without_player() -> void:
	weapon.base_damage = 10.0
	weapon.player_ref = null
	
	var result := weapon.get_actual_damage()
	
	assert_that(result).is_equal(10.0)

func test_get_actual_damage_multiplies_by_player_might() -> void:
	weapon.base_damage = 10.0
	player.might = 2.0
	weapon.player_ref = player
	
	var result := weapon.get_actual_damage()
	
	assert_that(result).is_equal(20.0)

func test_get_actual_fire_rate_returns_base_fire_rate_without_player() -> void:
	weapon.base_fire_rate = 2.0
	weapon.player_ref = null
	
	var result := weapon.get_actual_fire_rate()
	
	assert_that(result).is_equal(2.0)

func test_get_actual_fire_rate_multiplies_by_player_cooldown_mult() -> void:
	weapon.base_fire_rate = 2.0
	player.cooldown_mult = 0.5
	weapon.player_ref = player
	
	var result := weapon.get_actual_fire_rate()
	
	assert_that(result).is_equal(1.0)

func test_get_actual_area_returns_base_area_without_player() -> void:
	weapon.base_area = 1.5
	weapon.player_ref = null
	
	var result := weapon.get_actual_area()
	
	assert_that(result).is_equal(1.5)

func test_get_actual_area_multiplies_by_player_area() -> void:
	weapon.base_area = 2.0
	player.area = 1.5
	weapon.player_ref = player
	
	var result := weapon.get_actual_area()
	
	assert_that(result).is_equal(3.0)

func test_get_actual_range_returns_base_range_without_player() -> void:
	weapon.base_range = 300.0
	weapon.player_ref = null
	
	var result := weapon.get_actual_range()
	
	assert_that(result).is_equal(300.0)

func test_get_actual_range_multiplies_by_player_area() -> void:
	weapon.base_range = 200.0
	player.area = 2.0
	weapon.player_ref = player
	
	var result := weapon.get_actual_range()
	
	assert_that(result).is_equal(400.0)

func test_add_damage_stat_increases_total_damage_dealt() -> void:
	weapon.total_damage_dealt = 0.0
	
	weapon.add_damage_stat(25.0)
	
	assert_that(weapon.total_damage_dealt).is_equal(25.0)

func test_apply_level_upgrade_sets_level() -> void:
	weapon.level = 1
	
	weapon.apply_level_upgrade(2)
	
	assert_that(weapon.level).is_equal(2)

func test_get_upgrade_info_returns_dictionary_with_keys() -> void:
	var result := weapon.get_upgrade_info(2)
	
	assert_that(result.has("desc")).is_true()
	assert_that(result.has("rarity")).is_true()

