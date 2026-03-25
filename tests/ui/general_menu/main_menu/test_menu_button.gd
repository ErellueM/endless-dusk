extends GdUnitTestSuite

const SCENE_PATH = "res://main/ui/general_menu/main_menu/main_menu.tscn"

func test_initial_state():
	var runner = scene_runner(SCENE_PATH)
	var button = runner.scene()
	var label = runner.find_child("Label")
	
	# _ready() abwarten
	await runner.simulate_frames(1)
	
	# Check ob Initialfarbe korrekt gesetzt wurde
	assert_that(label.modulate).is_equal(button.color_normal)

func test_hover_behavior():
	var runner = scene_runner(SCENE_PATH)
	var button = runner.scene()
	var label = runner.find_child("Label")
	
	# Simuliere: Maus fährt über den Button
	runner.simulate_mouse_enter()
	await runner.simulate_frames(1)
	
	assert_that(label.modulate).is_equal(button.color_hover)
	
	# Simuliere: Maus verlässt den Button
	runner.simulate_mouse_exit()
	await runner.simulate_frames(1)
	
	assert_that(label.modulate).is_equal(button.color_normal)

func test_click_offset_and_color():
	var runner = scene_runner(SCENE_PATH)
	var button = runner.scene()
	var label = runner.find_child("Label")
	
	var initial_y = label.position.y
	var offset = button.click_offset_y
	
	# 1. Button runterdrücken (button_down)
	runner.simulate_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	await runner.simulate_frames(1)
	
	assert_that(label.modulate).is_equal(button.color_pressed)
	assert_that(label.position.y).is_equal(initial_y + offset)
	
	# 2. Button loslassen (button_up)
	runner.simulate_mouse_button_released(MOUSE_BUTTON_LEFT)
	await runner.simulate_frames(1)
	
	# Nach dem Loslassen ist die Maus meist noch über dem Button -> Hover Farbe
	assert_that(label.modulate).is_equal(button.color_hover)
	assert_that(label.position.y).is_equal(initial_y)

func test_custom_colors_from_inspector():
	var runner = scene_runner(SCENE_PATH)
	var button = runner.scene()
	var label = runner.find_child("Label")
	
	# Wir ändern die Export-Variablen im Test
	button.color_normal = Color.RED
	runner.invoke("_ready") # Nochmal triggern um Farbe zu setzen
	
	assert_that(label.modulate).is_equal(Color.RED)
