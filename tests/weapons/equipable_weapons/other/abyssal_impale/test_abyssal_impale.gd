extends GdUnitTestSuite

var weapon

func before_test():
	weapon = preload("res://main/weapons/equipable_weapons/other/abyssal_impale/abyssal_impale.tscn").instantiate()
	add_child(weapon)
	await get_tree().process_frame

func after_test():
	if weapon and is_instance_valid(weapon):
		weapon.queue_free()

func test_initial_values():
	assert_that(weapon.level).is_equal(1)
	assert_that(weapon.spike_count).is_greater(0)

func test_apply_level_upgrade():
	var initial_spikes = weapon.spike_count
	weapon.apply_level_upgrade(2)
	assert_that(weapon.level).is_equal(2)
	assert_that(weapon.spike_count).is_greater(initial_spikes)

func test_attack():
	var result = weapon.attack()
	assert_that(result).is_true()
