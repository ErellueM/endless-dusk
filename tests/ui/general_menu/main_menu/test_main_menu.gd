extends GdUnitTestSuite

const SCENE_UNDER_TEST = "res://main/ui/general_menu/main_menu/main_menu.tscn"


func test_music_starts_on_ready():
	# Wir erstellen einen Spy oder Mock für den MusicManager,
	# falls du sichergehen willst, dass er aufgerufen wurde.
	# Hier testen wir erst mal nur, ob die Szene ohne Fehler lädt.
	var runner = scene_runner(SCENE_UNDER_TEST)
	await runner.simulate_frames(1)

	# Wenn dein MusicManager ein Autoload ist, können wir prüfen,
	# ob er gerade etwas abspielt (falls dein MusicManager eine 'is_playing' Property hat)
	# assert_that(MusicManager.is_playing()).is_true()


# --- Tests ---


func test_navigation_to_character_selection():
	var runner = scene_runner(SCENE_UNDER_TEST)
	var tree = runner.get_tree()

	runner.invoke("_on_button_start_game_pressed")

	# Wir warten, bis der Pfad übereinstimmt (max. 2000ms)
	var target = "res://main/ui/CharacterSelection/CharacterSeletion.tscn"
	await yield_for_condition(func(): return tree.current_scene.scene_file_path == target, 2000)

	assert_str(tree.current_scene.scene_file_path).is_equal(target)


func test_navigation_to_settings():
	var runner = scene_runner(SCENE_UNDER_TEST)
	var tree = runner.get_tree()

	runner.invoke("_on_button_settings_pressed")

	var target = "res://main/ui/general_menu/settings_menu/settings.tscn"
	await yield_for_condition(func(): return tree.current_scene.scene_file_path == target, 2000)

	assert_str(tree.current_scene.scene_file_path).is_equal(target)


# --- Helper Funktion ---


func yield_for_condition(condition: Callable, timeout_ms: int) -> void:
	var start_time = Time.get_ticks_msec()
	while not condition.call():
		if Time.get_ticks_msec() - start_time > timeout_ms:
			# So gibt man in GdUnit4 eine benutzerdefinierte Fehlermeldung aus:
			(
				assert_bool(true)
				. override_failure_message(
					"Timeout: Die Szene hat sich nicht rechtzeitig geändert!"
				)
				. is_false()
			)
			return
		# Wir warten auf den nächsten Frame der Engine
		await get_tree().process_frame
