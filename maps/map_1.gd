extends Node2D

@onready var game_ui = $GameUI
@onready var game_manager = $GameManager
@onready var wave_handler = $WaveManager

var player: Node2D

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

func _ready():
	if Global.selected_character_scene:
		player = Global.selected_character_scene.instantiate()
		add_child(player)
		player.global_position = $PlayerSpawn.global_position

		player.xp_changed.connect(game_ui._on_player_xp_changed)
		player.health_changed.connect(game_ui._on_player_health_changed)

		player.leveled_up.connect(game_manager._on_player_leveled_up)

		game_ui._on_player_xp_changed(player.current_xp, player.max_xp)
		if player.health_component:
			game_ui._on_player_health_changed(
				player.health_component.current_health, player.health_component.max_health
			)

		# Camera
		var cam = $Camera2D
		cam.make_current()
		cam.target_node = player

		# Give the player to the spawner
		wave_handler.set_player(player)
	else:
		push_warning("⚠️ Kein Charakter ausgewählt – lade Default Player!")
