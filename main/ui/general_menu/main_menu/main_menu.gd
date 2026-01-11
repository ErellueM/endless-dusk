extends Node2D

# Pfad zur Szenen
const SCENE_CHARACTER_SELECTION = "res://main/ui/CharacterSelection/CharacterSeletion.tscn"
const SCENE_SETTINGS = "res://main/ui/general_menu/settings_menu/settings.tscn"
const SCENE_CREDITS = "res://main/ui/general_menu/credits_menu/credits.tscn"
const SCENE_MAIN = "res://main/ui/general_menu/main_menu/main_menu.tscn"

func _ready():
	MusicManager.play_music(preload("res://assets/audio/soundtracks/Endless_Dusk_Main_Theme.ogg"))

# wenn  Start-Button geklickt wird.
func _on_button_start_game_pressed():
	if ResourceLoader.exists(SCENE_CHARACTER_SELECTION):
		# Ersetze die aktuelle Szene (MainMenu) durch  Zielszene (CharacterSeletion)
		get_tree().change_scene_to_file(SCENE_CHARACTER_SELECTION)
	else:
		# Falls  Pfad falsch ist
		print("FEHLER: Zielszene nicht gefunden unter: ", SCENE_CHARACTER_SELECTION)

# wenn  Settings-Button geklickt wird.
func _on_button_settings_pressed():
	if ResourceLoader.exists(SCENE_SETTINGS):
		# Ersetze die aktuelle Szene (MainMenu) durch  Zielszene (CharacterSeletion)
		get_tree().change_scene_to_file(SCENE_SETTINGS)
	else:
		# Falls  Pfad falsch ist
		print("FEHLER: Zielszene nicht gefunden unter: ", SCENE_SETTINGS)

# wenn  Credits-Button geklickt wird.
func _on_button_credits_pressed():
	if ResourceLoader.exists(SCENE_CREDITS):
		# Ersetze die aktuelle Szene (MainMenu) durch  Zielszene (CharacterSeletion)
		get_tree().change_scene_to_file(SCENE_CREDITS)
	else:
		# Falls  Pfad falsch ist
		print("FEHLER: Zielszene nicht gefunden unter: ", SCENE_CREDITS)

# wenn go-back_button geklickt
func _on_button_back_pressed():
	if ResourceLoader.exists(SCENE_MAIN):
		# Ersetze die aktuelle Szene (MainMenu) durch  Zielszene (CharacterSeletion)
		get_tree().change_scene_to_file(SCENE_MAIN)
	else:
		# Falls  Pfad falsch ist
		print("FEHLER: Zielszene nicht gefunden unter: ", SCENE_MAIN)
