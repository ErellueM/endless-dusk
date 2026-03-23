extends GdUnitTestSuite

# Wir brauchen eine Test-Szene, die eine Kamera und dieses Skript enthält
# Struktur: 
# Node2D (Root)
#   -> Camera2D
#   -> Node2D (mit deinem Skript)
const SCENE_PATH = "res://main/ui/general_menu/main_menu/main_menu.tscn"

func test_parallax_calculation_center():
	var runner = scene_runner(SCENE_PATH)
	var viewport_size = runner.get_viewport_rect().size
	var center = viewport_size / 2.0
	
	# Maus exakt in die Mitte setzen
	runner.set_mouse_pos(center)
	
	# Einen Frame warten, damit _process ausgeführt wird
	await runner.simulate_frames(1)
	
	var camera = runner.find_child("Camera2D") as Camera2D
	# In der Mitte sollte die Kamera genau auf der Center-Position sein (dist_x/y = 0)
	assert_that(camera.position).is_equal(center)

func test_parallax_calculation_top_left():
	var runner = scene_runner(SCENE_PATH)
	var script_node = runner.find_child("ParallaxLogic") # Name deines Nodes mit Skript
	var strength = script_node.parallax_strength
	
	var viewport_size = runner.get_viewport_rect().size
	var center = viewport_size / 2.0
	
	# Maus ganz oben links (0,0) -> dist_x = -1, dist_y = -1
	runner.set_mouse_pos(Vector2.ZERO)
	
	await runner.simulate_frames(1)
	
	var camera = runner.find_child("Camera2D") as Camera2D
	# Erwartete Position: center + (-1, -1) * strength
	var expected_pos = center + Vector2(-1, -1) * strength
	assert_that(camera.position).is_equal(expected_pos)

func test_parallax_calculation_bottom_right():
	var runner = scene_runner(SCENE_PATH)
	var script_node = runner.find_child("ParallaxLogic")
	var strength = script_node.parallax_strength
	
	var viewport_size = runner.get_viewport_rect().size
	var center = viewport_size / 2.0
	
	# Maus ganz unten rechts
	runner.set_mouse_pos(viewport_size)
	
	await runner.simulate_frames(1)
	
	var camera = runner.find_child("Camera2D") as Camera2D
	# Erwartete Position: center + (1, 1) * strength
	var expected_pos = center + Vector2(1, 1) * strength
	assert_that(camera.position).is_equal(expected_pos)

func test_parallax_strength_impact():
	var runner = scene_runner(SCENE_PATH)
	var script_node = runner.find_child("ParallaxLogic")
	
	# Wir ändern die Stärke im Test
	script_node.parallax_strength = 50.0
	var viewport_size = runner.get_viewport_rect().size
	var center = viewport_size / 2.0
	
	# Maus ganz rechts
	runner.set_mouse_pos(Vector2(viewport_size.x, center.y))
	
	await runner.simulate_frames(1)
	
	var camera = runner.find_child("Camera2D") as Camera2D
	# Muss jetzt um 50 Pixel verschoben sein
	assert_float(camera.position.x).is_equal(center.x + 50.0)
