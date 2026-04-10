#extends GdUnitTestSuite
#
# Anpassung am Game-Manager notwendig, Test-endlos ! Standard auf failed in Gdot nicht möglich bei Timeout

#const SCENE_UNDER_TEST = "res://main/ui/general_menu/credits_menu/credits.tscn"
#const TARGET_SCENE = "res://main/ui/general_menu/main_menu/main_menu.tscn"
#
#func before_test() -> void:
#pass
#
## TEST 1: Erfolgreicher Wechsel
#func test_on_button_back_pressed_changes_scene():
#var runner = scene_runner(SCENE_UNDER_TEST)
#
## Trigger die Funktion
#runner.invoke("_on_button_back_pressed")
#
## Wir lassen den Runner bis zu 2000ms warten, bis die Bedingung wahr ist.
## Falls die Zeit abläuft, bricht GdUnit diesen Aufruf automatisch ab.
#await runner.wait_until(func():
#return get_tree().current_scene.scene_file_path == TARGET_SCENE
#, 2000)
#
## Jetzt prüfen wir das Ergebnis. Ist es falsch, schlägt der Test fehl (FAILED).
#var current_path = get_tree().current_scene.scene_file_path
#assert_str(current_path).override_failure_message(
#"FAILED: Szene wurde nicht gewechselt. Aktueller Pfad: " + current_path
#).is_equal(TARGET_SCENE)
#
#
## TEST 2: Fehlerfall
#func test_on_button_back_pressed_fails_gracefully_on_missing_file():
#var runner = scene_runner(SCENE_UNDER_TEST)
#
#runner.invoke("_on_button_back_pressed")
#
## Wir warten hier einfach eine feste Anzahl an Frames OHNE Schleife.
#await runner.simulate_frames(5)
#
## Check ob wir noch da sind
#assert_str(get_tree().current_scene.scene_file_path).is_equal(SCENE_UNDER_TEST)

extends GdUnitTestSuite

const SCENE_UNDER_TEST = "res://main/ui/general_menu/credits_menu/credits.tscn"
const TARGET_SCENE = "res://main/ui/general_menu/main_menu/main_menu.tscn"


func before_test() -> void:
	pass


# TEST 1: Immer fehlschlagen
func test_on_button_back_pressed_changes_scene():
	fail("FAILED: Dieser Test ist absichtlich auf FAILURE gesetzt.")


# TEST 2: Immer fehlschlagen
func test_on_button_back_pressed_fails_gracefully_on_missing_file():
	fail("FAILED: Dieser Test ist absichtlich auf FAILURE gesetzt.")
