# res://tests/ui/ingameUI/test_progress.gd
extends GdUnitTestSuite

const SCENE_PATH = "res://main/ui/ingameUI/game_ui.tscn"

func test_shader_time_updates_over_frames():
	var runner = scene_runner(SCENE_PATH)
	# Ersetze "ProgressRect" durch den tatsächlichen Namen deines Nodes im Scene Tree!
	var rect = runner.find_child("ProgressRect") 
	
	assert_that(rect).is_not_null()
	var mat = rect.material as ShaderMaterial
	
	var time_start = mat.get_shader_parameter("custom_time")
	assert_that(time_start).is_equal(0.0)
	
	await runner.simulate_frames(10, 0.1)
	
	var time_after = mat.get_shader_parameter("custom_time")
	assert_that(time_after).is_between(0.99, 1.01)

func test_shader_time_pauses_correctly():
	var runner = scene_runner(SCENE_PATH)
	var rect = runner.find_child("ProgressRect") # Auch hier anpassen
	var mat = rect.material as ShaderMaterial
	
	runner.get_tree().paused = true
	var time_before = mat.get_shader_parameter("custom_time")
	
	await runner.simulate_frames(10, 0.1)
	
	var time_after = mat.get_shader_parameter("custom_time")
	assert_that(time_after).is_equal(time_before)
	
	runner.get_tree().paused = false

func test_manual_time_reset():
	var runner = scene_runner(SCENE_PATH)
	var rect = runner.scene()
	var mat = rect.material as ShaderMaterial
	
	# Zeit manuell im Skript zurücksetzen
	rect.current_time = 0.0
	await runner.simulate_frames(1)
	
	assert_that(mat.get_shader_parameter("custom_time")).is_equal(rect.current_time)
