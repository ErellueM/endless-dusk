extends GdUnitTestSuite

var weapon


func before_test():
	weapon = (
		preload("res://main/weapons/equipable_weapons/range/phantom_glaive/phantom_glaive.tscn")
		. instantiate()
	)
	add_child(weapon)
	await get_tree().process_frame


func after_test():
	if weapon and is_instance_valid(weapon):
		weapon.queue_free()


func test_initial_values():
	assert_that(weapon.level).is_equal(1)


func test_apply_level_upgrade():
	weapon.apply_level_upgrade(2)
	assert_that(weapon.level).is_equal(2)


func test_attack():
	var result = weapon.attack()
	assert_that(result).is_true()
