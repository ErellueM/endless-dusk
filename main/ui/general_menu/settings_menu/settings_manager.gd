extends Node

const SETTINGS_PATH = "user://settings.cfg"

# ==========================================
# VARIABLEN & DEFAULTS
# ==========================================

# --- DISPLAY ---
signal show_fps_changed(show: bool)
var window_mode_index: int = 1  # 0: Windowed, 1: Borderless, 2: Fullscreen
var vsync_enabled: bool = true
var fps_limit_index: int = 2
var show_fps: bool = false:
	set(value):
		show_fps = value
		show_fps_changed.emit(show_fps)
var resolution_index: int = 1

# --- AUDIO ---
var master_volume: float = 0.5
var music_volume: float = 1.0
var sfx_volume: float = 1.0
var mute_on_focus_loss: bool = true

# --- CONTROLS ---
var mouse_movement: bool = false
var keybindings: Dictionary = {
	"move_up": KEY_W,
	"move_down": KEY_S,
	"move_left": KEY_A,
	"move_right": KEY_D,
	"interact": KEY_SPACE,
	"pause": KEY_ESCAPE
}

# --- GAMEPLAY ---
signal particles_setting_changed(is_reduced: bool)
var show_damage_numbers: bool = true
var enable_screenshake: bool = true
var reduce_particles: bool = false:
	set(value):
		reduce_particles = value
		particles_setting_changed.emit(reduce_particles)
var skip_transitions: bool = false

# ==========================================
# LADE & SPEICHER LOGIK
# ==========================================


func _ready():
	load_settings()


func save_settings():
	var config = ConfigFile.new()
	config.set_value("Display", "window_mode_index", window_mode_index)
	config.set_value("Display", "vsync_enabled", vsync_enabled)
	config.set_value("Display", "fps_limit_index", fps_limit_index)
	config.set_value("Display", "show_fps", show_fps)
	config.set_value("Display", "resolution_index", resolution_index)

	config.set_value("Audio", "master_volume", master_volume)
	config.set_value("Audio", "music_volume", music_volume)
	config.set_value("Audio", "sfx_volume", sfx_volume)
	config.set_value("Audio", "mute_on_focus_loss", mute_on_focus_loss)

	config.set_value("Controls", "mouse_movement", mouse_movement)
	config.set_value("Controls", "keybindings", keybindings)

	config.set_value("Gameplay", "show_damage_numbers", show_damage_numbers)
	config.set_value("Gameplay", "enable_screenshake", enable_screenshake)
	config.set_value("Gameplay", "reduce_particles", reduce_particles)
	config.set_value("Gameplay", "skip_transitions", skip_transitions)
	config.save(SETTINGS_PATH)


func load_settings():
	var config = ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		window_mode_index = config.get_value("Display", "window_mode_index", 1)
		vsync_enabled = config.get_value("Display", "vsync_enabled", true)
		fps_limit_index = config.get_value("Display", "fps_limit_index", 2)
		show_fps = config.get_value("Display", "show_fps", show_fps)
		resolution_index = config.get_value("Display", "resolution_index", 0)

		master_volume = config.get_value("Audio", "master_volume", 1.0)
		music_volume = config.get_value("Audio", "music_volume", 1.0)
		sfx_volume = config.get_value("Audio", "sfx_volume", 1.0)
		mute_on_focus_loss = config.get_value("Audio", "mute_on_focus_loss", true)

		mouse_movement = config.get_value("Controls", "mouse_movement", false)
		var saved_keys = config.get_value("Controls", "keybindings", {})
		for action in saved_keys:
			keybindings[action] = saved_keys[action]

		show_damage_numbers = config.get_value("Gameplay", "show_damage_numbers", true)
		enable_screenshake = config.get_value("Gameplay", "enable_screenshake", true)
		reduce_particles = config.get_value("Gameplay", "reduce_particles", false)
		skip_transitions = config.get_value("Gameplay", "skip_transitions", false)
	apply_settings()


# ==========================================
# EINSTELLUNGEN ANWENDEN
# ==========================================


func apply_settings():
	# --- DISPLAY ---
	match window_mode_index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)  # Borderless
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)  # Echtes Vollbild

	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if vsync_enabled else DisplayServer.VSYNC_DISABLED
	)

	apply_fps_limit()

	if window_mode_index == 0:
		match resolution_index:
			0:
				DisplayServer.window_set_size(Vector2i(1280, 720))
			1:
				DisplayServer.window_set_size(Vector2i(1920, 1080))
			2:
				DisplayServer.window_set_size(Vector2i(2560, 1440))
			3:
				DisplayServer.window_set_size(Vector2i(3840, 2160))

	# --- AUDIO ---
	var master_bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(master_volume))
	var music_bus = AudioServer.get_bus_index("Music")
	if music_bus != -1:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(music_volume))
	var sfx_bus = AudioServer.get_bus_index("SFX")
	if sfx_bus != -1:
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(sfx_volume))

	# --- GAMEPLAY ---
	if has_node("/root/SceneChanger"):
		var changer = get_node("/root/SceneChanger")
		changer.skip_transitions = skip_transitions

	# --- CONTROLS ---
	for action_name in keybindings.keys():
		var keycode = keybindings[action_name]
		if InputMap.has_action(action_name):
			InputMap.action_erase_events(action_name)
			var new_event = InputEventKey.new()
			new_event.keycode = keycode
			InputMap.action_add_event(action_name, new_event)

			var arrow_event = InputEventKey.new()
			if action_name == "move_up":
				arrow_event.keycode = KEY_UP
			elif action_name == "move_down":
				arrow_event.keycode = KEY_DOWN
			elif action_name == "move_left":
				arrow_event.keycode = KEY_LEFT
			elif action_name == "move_right":
				arrow_event.keycode = KEY_RIGHT
			else:
				arrow_event.keycode = KEY_NONE
			if arrow_event.keycode != KEY_NONE:
				InputMap.action_add_event(action_name, arrow_event)


func apply_fps_limit():
	match fps_limit_index:
		0:
			Engine.max_fps = 30
		1:
			Engine.max_fps = 60
		2:
			Engine.max_fps = 90
		3:
			Engine.max_fps = 120
		4:
			Engine.max_fps = 144
		5:
			Engine.max_fps = 240
		6:
			Engine.max_fps = 0


# ==========================================
# FOCUS LOSS (MUTE LOGIC)
# ==========================================


func _notification(what):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if mute_on_focus_loss:
			AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
			Engine.max_fps = 15
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		if mute_on_focus_loss:
			AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
			apply_fps_limit()
