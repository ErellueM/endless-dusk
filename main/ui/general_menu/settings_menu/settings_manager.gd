extends Node

const SETTINGS_PATH = "user://settings.cfg"

# --- DEFAULTS ---
# Display
var fullscreen: bool = true
var vsync_enabled: bool = true
var fps_limit_index: int = 2 # 0: 30, 1: 60, 2: Unlimited
var show_fps: bool = false
var resolution_index: int = 0 # 0: 1080p, 1: 720p, 2: 1440p

# Audio
var master_volume: float = 0.8
var music_volume: float = 1.0
var sfx_volume: float = 1.0
var mute_on_focus_loss: bool = true

# Controls (Keybindings)
var mouse_movement: bool = false
# Diese Dictionary speichert die tatsächlichen Godot-Keycodes
var keybindings: Dictionary = {
	"move_up": KEY_W,
	"move_down": KEY_S,
	"move_left": KEY_A,
	"move_right": KEY_D,
	"interact": KEY_SPACE,
	"pause": KEY_ESCAPE
}

# Gameplay
var show_damage_numbers: bool = true
var reduce_particles: bool = false
var skip_transitions: bool = false

func _ready():
	get_tree().root.focus_exited.connect(_on_window_focus_exited)
	get_tree().root.focus_entered.connect(_on_window_focus_entered)
	load_settings()

func save_settings():
	var config = ConfigFile.new()
	# Display
	config.set_value("Display", "fullscreen", fullscreen)
	config.set_value("Display", "vsync_enabled", vsync_enabled)
	config.set_value("Display", "fps_limit_index", fps_limit_index)
	config.set_value("Display", "show_fps", show_fps)
	config.set_value("Display", "resolution_index", resolution_index)
	# Audio
	config.set_value("Audio", "master_volume", master_volume)
	config.set_value("Audio", "music_volume", music_volume)
	config.set_value("Audio", "sfx_volume", sfx_volume)
	config.set_value("Audio", "mute_on_focus_loss", mute_on_focus_loss)
	# Controls
	config.set_value("Controls", "mouse_movement", mouse_movement)
	config.set_value("Controls", "keybindings", keybindings)
	# Gameplay
	config.set_value("Gameplay", "show_damage_numbers", show_damage_numbers)
	config.set_value("Gameplay", "reduce_particles", reduce_particles)
	config.set_value("Gameplay", "skip_transitions", skip_transitions)
	config.save(SETTINGS_PATH)

func load_settings():
	var config = ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		fullscreen = config.get_value("Display", "fullscreen", false)
		vsync_enabled = config.get_value("Display", "vsync_enabled", true)
		fps_limit_index = config.get_value("Display", "fps_limit_index", 2)
		show_fps = config.get_value("Display", "show_fps", show_fps)
		resolution_index = config.get_value("Display", "resolution_index", 0)
		
		master_volume = config.get_value("Audio", "master_volume", 1.0)
		music_volume = config.get_value("Audio", "music_volume", 1.0)
		sfx_volume = config.get_value("Audio", "sfx_volume", 1.0)
		mute_on_focus_loss = config.get_value("Audio", "mute_on_focus_loss", true)
		
		mouse_movement = config.get_value("Controls", "mouse_movement", false)
		# Lade die Keybindings (falls vorhanden) und überschreibe die Standards
		var saved_keys = config.get_value("Controls", "keybindings", {})
		for action in saved_keys:
			keybindings[action] = saved_keys[action]
			
		show_damage_numbers = config.get_value("Gameplay", "show_damage_numbers", true)
		reduce_particles = config.get_value("Gameplay", "reduce_particles", false)
		skip_transitions = config.get_value("Gameplay", "skip_transitions", false)
	apply_settings()

func apply_settings():
	# --- DISPLAY & AUDIO WIE VORHER ... ---
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync_enabled else DisplayServer.VSYNC_DISABLED)
	match fps_limit_index:
		0: Engine.max_fps = 30
		1: Engine.max_fps = 60
		2: Engine.max_fps = 90
		3: Engine.max_fps = 120
		4: Engine.max_fps = 144
		5: Engine.max_fps = 240
		6: Engine.max_fps = 0
	if not fullscreen:
		match resolution_index:
			0: DisplayServer.window_set_size(Vector2i(1920, 1080))
			1: DisplayServer.window_set_size(Vector2i(1280, 720))
			2: DisplayServer.window_set_size(Vector2i(2560, 1440))
			3: DisplayServer.window_set_size(Vector2i(3840, 2160)) # NEU: 4K hinzugefügt!
			
	var master_bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(master_volume))
	var music_bus = AudioServer.get_bus_index("Music")
	if music_bus != -1: AudioServer.set_bus_volume_db(music_bus, linear_to_db(music_volume))
	var sfx_bus = AudioServer.get_bus_index("SFX")
	if sfx_bus != -1: AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(sfx_volume))
	
	if has_node("/root/SceneChanger"):
		var changer = get_node("/root/SceneChanger")
		changer.skip_transitions = skip_transitions
			
	# --- CONTROLS (MIT PFEILTASTEN-FALLBACK) ---
	for action_name in keybindings.keys():
		var keycode = keybindings[action_name]
		if InputMap.has_action(action_name):
			InputMap.action_erase_events(action_name) # Alles löschen
			
			# 1. Die neue Spieler-Taste hinzufügen (z.B. "G")
			var new_event = InputEventKey.new()
			new_event.keycode = keycode
			InputMap.action_add_event(action_name, new_event)
			
			# 2. Pfeiltasten IMMER als Alternative hinzufügen!
			var arrow_event = InputEventKey.new()
			if action_name == "move_up": arrow_event.keycode = KEY_UP
			elif action_name == "move_down": arrow_event.keycode = KEY_DOWN
			elif action_name == "move_left": arrow_event.keycode = KEY_LEFT
			elif action_name == "move_right": arrow_event.keycode = KEY_RIGHT
			else: arrow_event.keycode = KEY_NONE # Für Interact/Pause keine Pfeiltasten
			
			if arrow_event.keycode != KEY_NONE:
				InputMap.action_add_event(action_name, arrow_event)

# --- FOCUS LOSS LOGIC ---
func _on_window_focus_exited():
	if mute_on_focus_loss:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)

func _on_window_focus_entered():
	if mute_on_focus_loss:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
