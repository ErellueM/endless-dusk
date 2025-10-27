extends Node2D

const SCENE_MAIN = "res://main/ui/general_menu/main_menu/main_menu.tscn"

# wenn go-back_button geklickt
func _on_button_back_pressed():
	if ResourceLoader.exists(SCENE_MAIN):
		# Ersetze die aktuelle Szene (MainMenu) durch  Zielszene (CharacterSeletion)
		get_tree().change_scene_to_file(SCENE_MAIN)
	else:
		# Falls  Pfad falsch ist
		print("FEHLER: Zielszene nicht gefunden unter: ", SCENE_MAIN)
