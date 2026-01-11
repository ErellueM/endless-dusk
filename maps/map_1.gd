extends Node2D

@onready var game_ui = $GameUI

func _ready():
	if Global.selected_character_scene:
		# Spieler instanzieren
		var player_instance = Global.selected_character_scene.instantiate()
		add_child(player_instance)
		player_instance.global_position = $PlayerSpawn.global_position
		
		#XP
		player_instance.xp_changed.connect(game_ui._on_player_xp_changed)
		player_instance.leveled_up.connect(game_ui._on_player_leveled_up)
		game_ui._on_player_xp_changed(player_instance.current_xp, player_instance.max_xp)
		
		# Kamera einrichten
		var cam = $Camera2D
		cam.make_current()
		cam.target_node = player_instance
	else:
		push_warning("⚠️ Kein Charakter ausgewählt – lade Default Player!")
