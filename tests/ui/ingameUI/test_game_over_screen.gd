extends GdUnitTestSuite

const SCENE_PATH = "res://main/ui/ingameUI/game_over_screen.tscn"

class MockPlayer extends Node2D:
	var level = 15
	func _init(): add_to_group("player")

class MockGameUI extends Node2D:
	var time_elapsed = 125.0
	func _init(): add_to_group("GameUI")

# Diese Funktion wird vor JEDEM Test aufgerufen
func before_test():
	# Sicherstellen, dass die Pause aus vorherigen Tests aufgehoben ist
	var tree = get_tree()
	if tree:
		tree.paused = false

func test_stats_display_calculation():
	var runner = scene_runner(SCENE_PATH)
	var game_over = runner.scene()
	
	# Mocks erstellen
	var player = auto_free(MockPlayer.new())
	var game_ui = auto_free(MockGameUI.new())
	
	# BESSER: Füge Mocks als Geschwister oder Kinder der Test-Szene hinzu,
	# anstatt sie global an 'root' zu hängen.
	game_over.add_sibling(player)
	game_over.add_sibling(game_ui)
	
	game_over.show_game_over()
	
	var stats_label = runner.find_child("StatsLabel") as Label
	assert_that(stats_label.text).contains("LEVEL: 15")
	assert_that(stats_label.text).contains("02:05")

# noch endlos-Schleife
#func test_restart_button_unpauses_game():
	#var runner = scene_runner(SCENE_PATH)
	#var tree = runner.scene().get_tree()
	#
	#tree.paused = true
	#
	## Falls _on_restart_pressed 'reload_current_scene' aufruft, 
	## wird dieser Test den Runner vermutlich abbrechen lassen.
	## Um das zu umgehen, prüfen wir hier nur die Methode, 
	## oder wir müssen das Skript so bauen, dass es reload nur im Spiel aufruft.
	#
	#if runner.scene().has_method("_on_restart_pressed"):
		## Wir rufen es auf, aber sei gewarnt: Wenn es reloadet, bricht es hier ab.
		#runner.invoke("_on_restart_pressed")
		#assert_that(tree.paused).is_false()

func test_quit_button_exists():
	var runner = scene_runner(SCENE_PATH)
	# Nur prüfen, ob der Button da ist und die Methode existiert,
	# um den Test-Runner nicht zu schließen.
	assert_that(runner.find_child("QuitButton")).is_not_null()
	assert_that(runner.scene().has_method("_on_quit_pressed")).is_true()
