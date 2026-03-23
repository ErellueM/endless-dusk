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

func test_navigation_to_character_selection():
	var runner = scene_runner(SCENE_UNDER_TEST)
	
	# Simuliere den Klick auf den Start-Button
	runner.invoke("_on_button_start_game_pressed")
	
	# 10 Frames warten für den Szenenwechsel
	await runner.simulate_frames(10)
	
	var current_scene = runner.get_tree().current_scene
	assert_that(current_scene.scene_file_path).is_equal("res://main/ui/CharacterSelection/CharacterSeletion.tscn")

func test_navigation_to_settings():
	var runner = scene_runner(SCENE_UNDER_TEST)
	
	runner.invoke("_on_button_settings_pressed")
	
	await runner.simulate_frames(10)
	
	var current_scene = runner.get_tree().current_scene
	assert_that(current_scene.scene_file_path).is_equal("res://main/ui/general_menu/settings_menu/settings.tscn")

func test_navigation_to_credits():
	var runner = scene_runner(SCENE_UNDER_TEST)
	
	runner.invoke("_on_button_credits_pressed")
	
	await runner.simulate_frames(10)
	
	var current_scene = runner.get_tree().current_scene
	assert_that(current_scene.scene_file_path).is_equal("res://main/ui/general_menu/credits_menu/credits.tscn")
