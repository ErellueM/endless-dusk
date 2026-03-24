extends GdUnitTestSuite

var map

func before_test():
	var script = load("res://maps/map_1.gd")
	map = Node2D.new()
	map.set_script(script)
	
	# Mock children
	var ui = Node.new()
	var manager = Node.new()
	var wave_handler = Node.new()
	var spawn = Node2D.new()
	var cam = Camera2D.new()
	
	map.add_child(ui)
	map.add_child(manager)
	manager.add_child(wave_handler)
	map.add_child(spawn)
	map.add_child(cam)
	
	map.game_ui = ui
	map.game_manager = manager
	map.wave_handler = wave_handler
	
	add_child(map)
	await get_tree().process_frame

func after_test():
	if map and is_instance_valid(map):
		map.queue_free()

func test_instantiation():
	assert_that(map).is_not_null()

func test_player_spawn_fallback():
	# Testest ohne validens Character in Global -> sollte eine Warning loggen aber nicht crashen
	Global.selected_character_scene = null
	map._ready()
	assert_that(map.player).is_null()
