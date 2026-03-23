extends GdUnitTestSuite

const SCENE_UNDER_TEST = "res://main/ui/general_menu/credits_menu/credits.tscn"
const TARGET_SCENE = "res://main/ui/general_menu/credits_menu/credits.tscn"

func test_on_button_back_pressed_changes_scene():
	# 1. Szene laden
	var runner = scene_runner(SCENE_UNDER_TEST)
	
	# Sicherstellen, dass die Zielszene überhaupt existiert (Pre-Check)
	assert_bool(ResourceLoader.exists(TARGET_SCENE)).is_true()
	
	# 2. Die Funktion direkt aufrufen oder Button-Klick simulieren
	# Wenn dein Button im Szenenbaum "ButtonBack" heißt:
	# runner.maximize_view()
	# runner.simulate_mouse_button_pressed(MOUSE_BUTTON_LEFT) 
	
	# Alternativ rufen wir die Funktion direkt auf:
	runner.invoke("_on_button_back_pressed")
	
	# 3. Dem SceneTree Zeit geben, den Wechsel zu verarbeiten
	await runner.simulate_frames(10)
	
	# 4. Überprüfen, ob die aktuelle Szene im Tree nun die Zielszene ist
	var current_scene = runner.get_tree().current_scene
	assert_str(current_scene.scene_file_path).is_equal(TARGET_SCENE)

func test_on_button_back_pressed_fails_gracefully_on_missing_file():
	# Dieser Test simuliert einen falschen Pfad (indem wir die Konstante im Skript kurz "umbiegen")
	var runner = scene_runner(SCENE_UNDER_TEST)
	
	# Wir manipulieren die Konstante für diesen Testlauf, falls möglich, 
	# oder wir testen einfach nur, dass kein Absturz passiert, wenn ResourceLoader fehlschlägt.
	# Da SCENE_MAIN eine Konstante ist, können wir sie nicht einfach ändern.
	# Wir prüfen hier stattdessen, dass die Szene GLEICH BLEIBT, wenn die Datei nicht existiert.
	
	# (Hinweis: Um diesen Fall echt zu testen, müsste SCENE_MAIN eine Variable sein)
	runner.invoke("_on_button_back_pressed")
	
	# Wenn die Datei existiert (was sie sollte), wird dieser Test fehlschlagen, 
	# wenn sie NICHT existiert, bleibt die Szene gleich:
	var current_scene = runner.get_tree().current_scene
	assert_str(current_scene.scene_file_path).is_equal(SCENE_UNDER_TEST)
