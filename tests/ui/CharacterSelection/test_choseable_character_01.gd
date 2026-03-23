extends GdUnitTestSuite

const SCENE_PATH = "res://main/ui/CharacterSelection/ChoseableCharacters/ChoseableCharacter_01.tscn"

func test_initialization_unlocked():
	# Erstellt einen Runner, der die Szene in den Baum lädt
	var runner = scene_runner(SCENE_PATH)
	
	# Zugriff auf das Skript und Setzen der Werte
	var p_name = "Hero"
	runner.set_property("character_name", p_name)
	runner.set_property("unlocked", true)
	
	# _ready() triggern
	await runner.simulate_frames(1)
	
	# Überprüfen, ob das Label den Namen übernommen hat
	var label = runner.find_child("Label") as Label
	assert_str(label.text).is_equal(p_name)
	
	# Überprüfen, ob die Optik NICHT gesperrt ist (Modulate sollte weiß/standard sein)
	var button = runner.find_child("TextureButton") as TextureButton
	assert_object(button.modulate).is_equal(Color.WHITE)

func test_initialization_locked():
	var runner = scene_runner(SCENE_PATH)
	runner.set_property("unlocked", false)
	runner.set_property("character_name", "Secret")
	
	await runner.simulate_frames(1)
	
	var label = runner.find_child("Label") as Label
	var button = runner.find_child("TextureButton") as TextureButton
	
	# Die "Locked" Logik prüfen
	assert_str(label.text).is_equal("???")
	assert_object(button.modulate).is_equal(Color(0, 0, 0, 0.5))

func test_on_pressed_unlocked_changes_scene():
	var runner = scene_runner(SCENE_PATH)
	runner.set_property("unlocked", true)
	
	# Wir simulieren den Klick auf den Button
	var button = runner.find_child("TextureButton")
	runner.maximize_view() # Optional: macht das Fenster für den Test sichtbar
	
	# Klick simulieren
	runner.simulate_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	
	# Da change_scene_to_file asynchron ist, kurz warten
	await runner.simulate_frames(5)
	
	# Prüfen, ob die globale Variable gesetzt wurde
	# (Hinweis: Global muss als Autoload im Projekt existieren)
	assert_object(Global.selected_character_scene).is_not_null()

func test_on_pressed_locked_does_nothing():
	var runner = scene_runner(SCENE_PATH)
	runner.set_property("unlocked", false)
	Global.selected_character_scene = null
	
	# Klick auf gesperrten Charakter
	runner.invoke("_on_pressed")
	
	# Globaler State darf sich nicht geändert haben
	assert_object(Global.selected_character_scene).is_null()
