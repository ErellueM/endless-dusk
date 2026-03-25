extends GdUnitTestSuite

var weapon

func before_test():
	weapon = preload("res://main/weapons/equipable_weapons/aura/ice_aura/ice_aura.tscn").instantiate()
	add_child(weapon)
	await get_tree().process_frame

func after_test():
	if weapon and is_instance_valid(weapon):
		weapon.queue_free()

func test_initial_values():
	assert_that(weapon.level).is_equal(1)
	assert_that(weapon.slowness_factor).is_greater_equal(0.0)

func test_apply_level_upgrade():
	var initial_area = weapon.base_area
	weapon.apply_level_upgrade(2)
	assert_that(weapon.level).is_equal(2)
	assert_that(weapon.base_area).is_greater(initial_area)
