extends GdUnitTestSuite

var player: CharacterBody2D


func before_test():
	player = preload("res://main/entities/player.tscn").instantiate()
	add_child(player)
	await get_tree().process_frame


func after_test():
	if player and is_instance_valid(player):
		player.queue_free()


func test_gain_xp_increases_current_xp():
	var initial_xp = player.current_xp

	player.gain_xp(5)

	assert_that(player.current_xp).is_greater(initial_xp)


func test_gain_xp_triggers_level_up():
	var leveled := false
	player.leveled_up.connect(func(): leveled = true)

	player.gain_xp(100)

	assert_that(leveled).is_true()


func test_gain_xp_emits_xp_changed():
	var emitted := false

	player.xp_changed.connect(func(current, max_val): emitted = true)

	player.gain_xp(1)

	assert_that(emitted).is_true()


func test_take_damage_reduces_health():
	var health = player.health_component
	var before = health.current_health

	player.take_damage(10)
	await get_tree().process_frame

	assert_that(health.current_health).is_less(before)


func test_armor_reduces_damage():
	player.armor = 5

	var health = player.health_component
	var before = health.current_health

	player.take_damage(10)

	await get_tree().process_frame

	assert_that(health.current_health).is_equal(before - 5)


func test_heal_increases_health():
	var health = player.health_component

	health.current_health = 50
	player.heal(10)

	assert_that(health.current_health).is_equal(60)


func test_health_changed_signal_emitted_on_damage():
	var emitted := false

	player.health_changed.connect(func(current, max_val): emitted = true)

	player.take_damage(10)
	await get_tree().process_frame

	assert_that(emitted).is_true()


func test_update_magnet_scales_radius():
	player.magnet_mult = 2.0

	var shape = player.magnet_shape.shape
	var base_radius = shape.radius

	player.update_magnet()

	assert_that(shape.radius).is_equal(base_radius * 2.0)


func test_die_changes_game_state():
	var manager = Node.new()
	manager.add_to_group("Managers")
	manager.GameState = {DEAD = 1}

	var called := false
	manager.change_state = func(state): called = true

	get_tree().current_scene.add_child(manager)

	player.die()

	assert_that(called).is_true()
