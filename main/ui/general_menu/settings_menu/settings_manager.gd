extends Node

const SETTINGS_PATH = "user://settings.cfg"

# Standardwerte
var master_volume: float = 1.0
var is_muted: bool = false
var vsync_enabled: bool = true
var fullscreen: bool = false
var skip_transitions: bool = false

func _ready():
	load_settings()

func save_settings():
	var config = ConfigFile.new()
	config.set_value("Audio", "master_volume", master_volume)
	config.set_value("Audio", "is_muted", is_muted)
	config.set_value("Display", "vsync_enabled", vsync_enabled)
	config.set_value("Display", "fullscreen", fullscreen)
	config.set_value("Accessibility", "skip_transitions", skip_transitions)
	config.save(SETTINGS_PATH)

func load_settings():
	var config = ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		master_volume = config.get_value("Audio", "master_volume", 1.0)
		is_muted = config.get_value("Audio", "is_muted", false)
		vsync_enabled = config.get_value("Display", "vsync_enabled", true)
		fullscreen = config.get_value("Display", "fullscreen", false)
		skip_transitions = config.get_value("Accessibility", "skip_transitions", false)
		
	apply_settings()

func apply_settings():
	# Audio anwenden
	var master_bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(master_volume))
	AudioServer.set_bus_mute(master_bus, is_muted)
	
	# Grafik anwenden
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync_enabled else DisplayServer.VSYNC_DISABLED)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	
	# SceneChanger anwenden (falls er existiert)
	if has_node("/root/SceneChanger"):
		var changer = get_node("/root/SceneChanger")
		changer.skip_transitions = skip_transitions
