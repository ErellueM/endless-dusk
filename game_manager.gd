extends Node

# Wir definieren die Zustände als ENUM (eine Liste von Namen)
enum GameState { PLAYING, PAUSED, LEVEL_UP, DEAD }

# Wir speichern den aktuellen Zustand
var current_state = GameState.PLAYING

# --- REFERENZEN ---
# Ziehe hier später im Inspector deine UI-Elemente rein!
@export var pause_menu : CanvasLayer
@export var level_up_screen : CanvasLayer

func _ready():
	# Zum Start sicherstellen, dass alles aus ist
	if pause_menu: pause_menu.hide()
	if level_up_screen: level_up_screen.hide()
	get_tree().paused = false

func _input(event):
	# Wir prüfen auf die Pause-Taste (ESC)
	if event.is_action_pressed("pause"):
		# Wenn wir gerade Spielen -> Pausieren
		if current_state == GameState.PLAYING:
			change_state(GameState.PAUSED)
		# Wenn wir schon Pausiert sind -> Weiter spielen
		elif current_state == GameState.PAUSED:
			change_state(GameState.PLAYING)
		# WICHTIG: Wenn current_state == LEVEL_UP ist, passiert HIER NICHTS.
		# Die Taste wird also ignoriert.
	if event.is_action_pressed("test"):
		# Wenn wir gerade Spielen -> Pausieren
		if current_state == GameState.PLAYING:
			change_state(GameState.LEVEL_UP)
		# Wenn wir schon Pausiert sind -> Weiter spielen
		elif current_state == GameState.LEVEL_UP:
			change_state(GameState.PLAYING)

# Die Herzstück-Funktion
func change_state(new_state):
	current_state = new_state
	
	match current_state:
		GameState.PLAYING:
			get_tree().paused = false
			pause_menu.hide()
			level_up_screen.hide()
			# Maus einfangen (falls FPS/Action Game)
			# Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
		GameState.PAUSED:
			get_tree().paused = true
			pause_menu.show()
			# Maus zeigen
			# Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			
		GameState.LEVEL_UP:
			get_tree().paused = true
			# Level Up Screen zeigen
			level_up_screen.show()
			# Sicherstellen, dass das Pause-Menü weg ist
			pause_menu.hide() 
			# Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
