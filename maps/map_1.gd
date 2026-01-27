extends Node2D

@onready var game_ui = $GameUI
@onready var wave_handler = $GameManager/WaveHandler

var player: Node2D
func _ready():
	if Global.selected_character_scene:
		player = Global.selected_character_scene.instantiate()
		add_child(player)
		player.global_position = $PlayerSpawn.global_position

		# XP
		player.xp_changed.connect(game_ui._on_player_xp_changed)
		player.leveled_up.connect(game_ui._on_player_leveled_up)
		game_ui._on_player_xp_changed(player.current_xp, player.max_xp)

		# Camera
		var cam = $Camera2D
		cam.make_current()
		cam.target_node = player

		# Give the player to the spawner
		wave_handler.set_player(player)
	else:
		push_warning("⚠️ Kein Charakter ausgewählt – lade Default Player!")
