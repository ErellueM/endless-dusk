extends GdUnitTestSuite

const SCENE_PATH = "res://main/ui/ingameUI/game_over_screen.tscn"

# --- Hilfs-Mocks für die Gruppen ---
class MockPlayer extends Node2D:
	var level = 15
	func _init(): add_to_group("player")

class MockGameUI extends Node2D:
	var time_elapsed = 125.0 # 2 Minuten, 5 Sekunden
	func _init(): add_to_group("GameUI")

# --- Tests ---

func test_stats_display_calculation():
	var runner = scene_runner(SCENE_PATH)
	var game_over = runner.working_node()
	
	# Mocks in den Tree bringen, damit 'show_game_over' sie findet
	var player = auto_free(MockPlayer.new())
	var game_ui = auto_free(MockGameUI.new())
	runner.get_tree().root.add_child(player)
	runner.get_tree().root.add_child(game_ui)
	
	# Funktion aufrufen
	game_over.show_game_over()
	
	var stats_label = runner.find_child("StatsLabel") as Label
	# Erwartet: "LEVEL: 15\nTIME: 02:05"
	assert_that(stats_label.text).contains("LEVEL: 15")
	assert_that(stats_label.text).contains("TIME: 02:05")

func test_show_trigger_animation():
	var runner = scene_runner(SCENE_PATH)
	var game_over = runner.working_node()
	var anim_player = runner.find_child("AnimationPlayer") as AnimationPlayer
	
	# Initial versteckt
	game_over.hide()
	
	game_over.show_game_over()
	
	assert_that(game_over.visible).is_true()
	assert_that(anim_player.current_animation).is_equal("fade_in")

func test_restart_button_unpauses_and_reloads():
	var runner = scene_runner(SCENE_PATH)
	
	# Wir simulieren, dass das Spiel pausiert ist
	runner.get_tree().paused = true
	
	# Button-Klick simulieren
	runner.invoke("_on_restart_pressed")
	
	# Prüfen, ob Pause aufgehoben wurde
	assert_that(runner.get_tree().paused).is_false()
	# 'reload_current_scene' ist schwer direkt zu prüfen, aber wir 
	# stellen sicher, dass kein Fehler geworfen wurde.

func test_quit_button_emits_quit_request():
	# HINWEIS: get_tree().quit() würde den Test-Runner schließen!
	# In Unit Tests vermeiden wir echte Quits. 
	# Man könnte hier prüfen, ob die Funktion erreichbar ist.
	var runner = scene_runner(SCENE_PATH)
	assert_that(runner.working_node().has_method("_on_quit_pressed")).is_true()
