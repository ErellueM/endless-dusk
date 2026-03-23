# Pfad zu deiner TextureRect.tscn (oder der Szene, die dieses Skript nutzt)
extends GdUnitTestSuite

const SCENE_PATH = "res://main/ui/ingameUI/game_ui.tscn"

func test_shader_time_updates_over_frames():
	var runner = scene_runner(SCENE_PATH)
	var rect = runner.working_node() as TextureRect
	
	# Sicherstellen, dass ein ShaderMaterial vorhanden ist
	assert_that(rect.material).is_instanceof(ShaderMaterial)
	var mat = rect.material as ShaderMaterial
	
	# 1. Startwert prüfen
	var time_start = mat.get_shader_parameter("custom_time")
	assert_that(time_start).is_equal(0.0)
	
	# 2. Wir simulieren 10 Frames mit einer festen Delta-Zeit (z.B. 0.1s pro Frame)
	# Insgesamt vergeht also 1 Sekunde
	await runner.simulate_frames(10, 0.1)
	
	# 3. Prüfen, ob die Zeit im Shader angekommen ist
	var time_after = mat.get_shader_parameter("custom_time")
	
	# Die Zeit sollte jetzt ca. 1.0 sein (10 * 0.1)
	assert_that(time_after).is_between(0.99, 1.01)
	assert_that(rect.current_time).is_equal(time_after)

func test_shader_time_pauses_correctly():
	var runner = scene_runner(SCENE_PATH)
	var rect = runner.working_node() as TextureRect
	var mat = rect.material as ShaderMaterial
	
	# Spiel pausieren
	runner.get_tree().paused = true
	
	var time_before = rect.current_time
	
	# Wir warten 10 Frames ab
	await runner.simulate_frames(10, 0.1)
	
	# Die Zeit darf sich NICHT verändert haben
	var time_after = mat.get_shader_parameter("custom_time")
	assert_that(time_after).is_equal(time_before)
	
	# Aufräumen (Pause aufheben)
	runner.get_tree().paused = false

func test_manual_time_reset():
	var runner = scene_runner(SCENE_PATH)
	var rect = runner.working_node()
	var mat = rect.material as ShaderMaterial
	
	# Zeit manuell im Skript zurücksetzen
	rect.current_time = 0.0
	await runner.simulate_frames(1)
	
	assert_that(mat.get_shader_parameter("custom_time")).is_equal(rect.current_time)
