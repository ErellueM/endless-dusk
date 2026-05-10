extends Node2D

# Pfad zur Szenen
const SCENE_CHARACTER_SELECTION = "res://main/ui/general_menu/hub_menu/hub_menu.tscn"#"res://main/ui/CharacterSelection/CharacterSeletion.tscn"
const SCENE_SETTINGS = "res://main/ui/general_menu/settings_menu/settings_menu.tscn"
const SCENE_CREDITS = "res://main/ui/general_menu/credits_menu/credits.tscn"
const SCENE_MAIN = "res://main/ui/general_menu/main_menu/main_menu.tscn"


func _ready():
	MusicManager.play_music(preload("res://assets/audio/soundtracks/Endless_Dusk_Main_Theme.ogg"))

func _input(event):
	if event.is_action_pressed("ui_screenshot"):
		var img = get_viewport().get_texture().get_image()
		var scale_factor = 1.5 
		var new_width = img.get_width() * scale_factor
		var new_height = img.get_height() * scale_factor
		img.resize(new_width, new_height, Image.INTERPOLATE_NEAREST)
		var time_string = Time.get_datetime_string_from_system().replace(":", "-")
		var file_path = "user://screenshot_%s.png" % time_string
		img.save_png(file_path)
		print("Screenshot gespeichert unter: ", file_path)

# wenn  Start-Button geklickt wird.
func _on_button_start_game_pressed():
	if ResourceLoader.exists(SCENE_CHARACTER_SELECTION):
		# Ersetze die aktuelle Szene (MainMenu) durch  Zielszene (CharacterSeletion)
		SceneChanger.change_scene(SCENE_CHARACTER_SELECTION)
	else:
		# Falls  Pfad falsch ist
		print("FEHLER: Zielszene nicht gefunden unter: ", SCENE_CHARACTER_SELECTION)


# wenn  Settings-Button geklickt wird.
func _on_button_settings_pressed():
	if ResourceLoader.exists(SCENE_SETTINGS):
		# Ersetze die aktuelle Szene (MainMenu) durch  Zielszene (CharacterSeletion)
		SceneChanger.change_scene(SCENE_SETTINGS)
	else:
		# Falls  Pfad falsch ist
		print("FEHLER: Zielszene nicht gefunden unter: ", SCENE_SETTINGS)


# wenn  Credits-Button geklickt wird.
func _on_button_credits_pressed():
	if ResourceLoader.exists(SCENE_CREDITS):
		# Ersetze die aktuelle Szene (MainMenu) durch  Zielszene (CharacterSeletion)
		SceneChanger.change_scene(SCENE_CREDITS)
	else:
		# Falls  Pfad falsch ist
		print("FEHLER: Zielszene nicht gefunden unter: ", SCENE_CREDITS)


# wenn go-back_button geklickt
func _on_button_back_pressed():
	if ResourceLoader.exists(SCENE_MAIN):
		# Ersetze die aktuelle Szene (MainMenu) durch  Zielszene (CharacterSeletion)
		SceneChanger.change_scene(SCENE_MAIN)
	else:
		# Falls  Pfad falsch ist
		print("FEHLER: Zielszene nicht gefunden unter: ", SCENE_MAIN)


func _on_quit_button_pressed():
	get_tree().quit()
