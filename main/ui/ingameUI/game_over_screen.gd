extends CanvasLayer

@onready var anim_player = $AnimationPlayer
@onready var stats_label = $UI_Container/StatsLabel
@onready var restart_button = $UI_Container/ButtonContainer/RestartButton
@onready var quit_button = $UI_Container/ButtonContainer/QuitButton

func _ready():
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func show_game_over():
	var final_level = 1
	var final_time = "00:00"
	
	var player = get_tree().get_first_node_in_group("player")
	if player: final_level = player.level
		
	var game_ui = get_tree().get_first_node_in_group("GameUI")
	if game_ui and "time_elapsed" in game_ui:
		var minutes = int(game_ui.time_elapsed / 60)
		var seconds = int(game_ui.time_elapsed) % 60
		final_time = "%02d:%02d" % [minutes, seconds]
		
	stats_label.text = "LEVEL: " + str(final_level) + "\nTIME: " + final_time
	show()
	anim_player.play("fade_in")

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().quit()
