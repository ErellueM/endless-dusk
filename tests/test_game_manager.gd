extends GdUnitTestSuite

var game_manager


func before_test():
	var script = load("res://game_manager.gd")
	game_manager = Node.new()
	game_manager.set_script(script)

	# Mock Screens
	game_manager.pause_menu = CanvasLayer.new()
	game_manager.level_up_screen = CanvasLayer.new()
	game_manager.game_over_screen = CanvasLayer.new()

	add_child(game_manager)
	await get_tree().process_frame


func after_test():
	if game_manager and is_instance_valid(game_manager):
		game_manager.queue_free()


func test_initial_state():
	assert_that(game_manager.current_state).is_equal(0)  # GameState.PLAYING


func test_change_state_to_paused():
	game_manager.change_state(1)  # GameState.PAUSED
	assert_that(game_manager.current_state).is_equal(1)
	assert_that(get_tree().paused).is_true()


func test_change_state_to_playing():
	game_manager.change_state(0)  # Play
	assert_that(get_tree().paused).is_false()


func test_player_leveled_up():
	game_manager._on_player_leveled_up()
	assert_that(game_manager.current_state).is_equal(2)  # GameState.LEVEL_UP
