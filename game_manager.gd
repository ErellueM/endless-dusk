extends Node

enum GameState { PLAYING, PAUSED, LEVEL_UP, DEAD }
var current_state = GameState.PLAYING

@export var pause_menu : CanvasLayer
@export var level_up_screen : CanvasLayer
@export var game_over_screen : CanvasLayer

func _ready():
	Global.reset_run_stats()
	if pause_menu: pause_menu.hide()
	if level_up_screen: level_up_screen.hide()
	if game_over_screen: game_over_screen.hide()
	get_tree().paused = false

func _input(event):
	if event.is_action_pressed("pause"): #esc
		if current_state == GameState.PLAYING:
			change_state(GameState.PAUSED)
		elif current_state == GameState.PAUSED:
			change_state(GameState.PLAYING)
			
	if event.is_action_pressed("test"): #t
		if current_state == GameState.PLAYING:
			change_state(GameState.LEVEL_UP)
		elif current_state == GameState.LEVEL_UP:
			change_state(GameState.PLAYING)

func change_state(new_state):
	current_state = new_state
	
	match current_state:
		GameState.PLAYING:
			get_tree().paused = false
			pause_menu.hide()
			level_up_screen.hide()
			#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
		GameState.PAUSED:
			get_tree().paused = true
			pause_menu.show()
			#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			
		GameState.LEVEL_UP:
			get_tree().paused = true
			level_up_screen.show()
			pause_menu.hide() 
			#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			
		GameState.DEAD:
			get_tree().paused = true
			pause_menu.hide()
			level_up_screen.hide()
			if game_over_screen:
				game_over_screen.show_game_over()
			#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			
func _on_player_leveled_up():
	change_state(GameState.LEVEL_UP)
