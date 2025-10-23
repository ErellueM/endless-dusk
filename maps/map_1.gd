extends Node2D

func _ready():
	if Global.selected_character_scene:
		# Spieler instanzieren
		var player_instance = Global.selected_character_scene.instantiate()
		add_child(player_instance)
		player_instance.global_position = $PlayerSpawn.global_position

		# Kamera einrichten
		var cam = $Camera2D
		cam.make_current()
		cam.target_node = player_instance
	else:
		push_warning("⚠️ Kein Charakter ausgewählt – lade Default Player!")
