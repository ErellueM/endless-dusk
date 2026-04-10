extends GdUnitTestSuite

const SCENE_PATH = "res://main/ui/CharacterSelection/ChoseableCharacters/ChoseableCharacter_01.tscn"


func test_initialization_unlocked():
	var runner = scene_runner(SCENE_PATH)

	var p_name = "Hero"
	runner.set_property("character_name", p_name)
	runner.set_property("unlocked", true)

	# Manually trigger the update function if your script has one (e.g., setup_ui())
	# If your logic is ONLY in _ready, you might need to call it manually:
	runner.invoke("_ready")
	await runner.simulate_frames(1)

	var label = runner.find_child("Label") as Label
	# Cast to string to avoid StringName mismatches
	assert_str(label.text).is_equal(str(p_name))

	var button = runner.find_child("TextureButton") as TextureButton
	assert_object(button.modulate).is_equal(Color.WHITE)


func test_initialization_locked():
	var runner = scene_runner(SCENE_PATH)
	runner.set_property("unlocked", false)
	runner.set_property("character_name", "Secret")

	runner.invoke("_ready")
	await runner.simulate_frames(1)

	var label = runner.find_child("Label") as Label
	var button = runner.find_child("TextureButton") as TextureButton

	assert_str(label.text).is_equal("???")
	# Use is_equal with a small margin if comparing floating point colors
	assert_object(button.modulate).is_equal(Color(0, 0, 0, 0.5))


# Prüfe Global-Skript
#func test_on_pressed_unlocked_changes_scene():
#var runner = scene_runner(SCENE_PATH)
#runner.set_property("unlocked", true)
#
## WICHTIG: Sicherstellen, dass die Variable vorher leer ist
#Global.selected_character_scene = null
#
## Wir rufen die Funktion direkt auf, statt einen echten Klick zu simulieren.
## Das ist stabiler für Unit-Tests, da wir die Logik prüfen wollen, nicht die Godot-Engine-Physik.
#runner.invoke("_on_pressed")
#
## Wir warten nur EINEN Frame, um Godot Zeit für die Zuweisung zu geben
#await get_tree().process_frame
#
## Prüfen, ob die globale Variable gesetzt wurde
#assert_object(Global.selected_character_scene).is_not_null()
#
## Falls du den Pfad prüfen willst:
## assert_str(Global.selected_character_scene).is_equal("res://path/to/character.tscn")


func test_on_pressed_locked_does_nothing():
	var runner = scene_runner(SCENE_PATH)
	runner.set_property("unlocked", false)
	Global.selected_character_scene = null

	# Klick auf gesperrten Charakter
	runner.invoke("_on_pressed")

	# Globaler State darf sich nicht geändert haben
	assert_object(Global.selected_character_scene).is_null()
