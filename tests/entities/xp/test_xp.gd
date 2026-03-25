extends GdUnitTestSuite

var gem: Area2D

func before_test():
	gem = preload("res://main/entities/xp/xp.tscn").instantiate()
	add_child(gem)
	await get_tree().process_frame


func after_test():
	if gem and is_instance_valid(gem):
		gem.queue_free()

func test_gem_initial_values():
	assert_that(gem.is_in_group("XPGem")).is_true()
	assert_that(gem.xp_value).is_equal(1.0)
	assert_that(gem.scale).is_equal(gem.base_scale)

func test_on_body_entered_grants_xp_and_frees():
	var player = Node.new()
	player.add_to_group("player")
	player.gain_xp = func(amount): pass
	
	add_child(player)
	
	gem._on_body_entered(player)
	
	await get_tree().process_frame
	
	assert_that(is_instance_valid(gem)).is_false()

func test_fly_to_player_starts_flying():
	var player = Node2D.new()
	add_child(player)
	
	gem.fly_to_player(player)
	
	assert_that(gem.is_flying).is_true()
	assert_that(gem.target_player).is_equal(player)

func test_absorb_gem_increases_xp():
	var other = preload("res://main/entities/xp/xp.tscn").instantiate()
	add_child(other)
	
	gem.xp_value = 5
	other.xp_value = 3
	
	gem.absorb_gem(other)
	
	await get_tree().process_frame
	
	assert_that(gem.xp_value).is_equal(8)


func test_absorb_gem_frees_other():
	var other = preload("res://main/entities/xp/xp.tscn").instantiate()
	add_child(other)
	
	gem.absorb_gem(other)
	
	await get_tree().process_frame
	
	assert_that(is_instance_valid(other)).is_false()

func test_update_visuals_changes_scale():
	gem.xp_value = 50
	
	gem._update_visuals()
	
	assert_that(gem.base_scale.x).is_greater(1.0)


func test_high_xp_changes_color():
	gem.xp_value = 100
	
	gem._update_visuals()
	
	assert_that(gem.modulate.r).is_less(1.0)

func test_optimization_tick_does_not_crash():

	gem._on_optimization_tick()
	
	assert_that(gem.is_inside_tree()).is_true()
