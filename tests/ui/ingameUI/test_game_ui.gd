extends GdUnitTestSuite

const SCENE_PATH = "res://main/ui/ingameUI/game_ui.tscn"

func test_initialization_and_group():
	var runner = scene_runner(SCENE_PATH)
	var ui = runner.scene()
	
	# Prüfen, ob die UI sich korrekt in die Gruppe einträgt
	assert_that(ui.is_in_group("GameUI")).is_true()
	assert_that(ui.time_elapsed).is_equal(0.0)

func test_timer_progression():
	var runner = scene_runner(SCENE_PATH)
	var ui = runner.scene()
	var label = runner.find_child("TimerLabel", true, false) as Label
	
	# Wir simulieren den Ablauf von 65 Sekunden
	# (simulate_frames mit Delta-Zeit Simulation)
	await runner.simulate_frames(65, 1.0) # 65 Schritte à 1 Sekunde
	
	assert_that(ui.time_elapsed).is_between(64.9, 65.1)
	# Erwartetes Format: "01:05"
	assert_that(label.text).is_equal("01:05")

func test_timer_pauses_when_game_is_paused():
	var runner = scene_runner(SCENE_PATH)
	var ui = runner.scene()
	
	# Spiel pausieren
	runner.scene().paused = true
	var time_before = ui.time_elapsed
	
	await runner.simulate_frames(10, 0.1)
	
	# Zeit darf sich nicht verändert haben
	assert_that(ui.time_elapsed).is_equal(time_before)
	
	# Aufräumen für andere Tests
	runner.get_tree().paused = false

func test_xp_bar_updates_on_signal():
	var runner = scene_runner(SCENE_PATH)
	var ui = runner.scene()
	var exp_bar = runner.find_child("ExpBar", true, false) as TextureProgressBar
	
	# Signal-Funktion direkt aufrufen (Simuliert das Signal vom Spieler)
	ui._on_player_xp_changed(50, 100)
	
	assert_that(exp_bar.max_value).is_equal(100.0)
	assert_that(exp_bar.value).is_equal(50.0)

func test_health_bar_updates_on_signal():
	var runner = scene_runner(SCENE_PATH)
	var ui = runner.scene()
	var health_bar = runner.find_child("HealthBar", true, false) as TextureProgressBar
	
	ui._on_player_health_changed(20, 80)
	
	assert_that(health_bar.max_value).is_equal(80.0)
	assert_that(health_bar.value).is_equal(20.0)
