extends CanvasLayer

@onready var master_bus = AudioServer.get_bus_index("Master")

# --- PAGES ---
@onready var page_display = $MarginContainer/HBoxContainer/ScrollContainer/MarginContainer/Pages/Page_Display
@onready var page_audio = $MarginContainer/HBoxContainer/ScrollContainer/MarginContainer/Pages/Page_Audio
@onready var page_controls = $MarginContainer/HBoxContainer/ScrollContainer/MarginContainer/Pages/Page_Controls
@onready var page_gameplay = $MarginContainer/HBoxContainer/ScrollContainer/MarginContainer/Pages/Page_Gameplay

# --- UI ELEMENTS ---
# Display
@onready var opt_window = $MarginContainer/HBoxContainer/ScrollContainer/MarginContainer/Pages/Page_Display/Grid/Option_Window
@onready var opt_resolution = $MarginContainer/HBoxContainer/ScrollContainer/MarginContainer/Pages/Page_Display/Grid/Option_Resolution
@onready var btn_vsync = $MarginContainer/HBoxContainer/ScrollContainer/MarginContainer/Pages/Page_Display/Grid/CheckBox_Vsync
@onready var opt_fps = $MarginContainer/HBoxContainer/ScrollContainer/MarginContainer/Pages/Page_Display/Grid/Option_FPS
@onready var btn_show_fps = $MarginContainer/HBoxContainer/ScrollContainer/MarginContainer/Pages/Page_Display/Grid/Option_ShowFps

# Audio
@onready var slider_master = $MarginContainer/HBoxContainer/ScrollContainer/MarginContainer/Pages/Page_Audio/Grid/HSlider_Volume
@onready var slider_music = $MarginContainer/HBoxContainer/ScrollContainer/MarginContainer/Pages/Page_Audio/Grid/HSlider_Music
@onready var slider_sfx = $MarginContainer/HBoxContainer/ScrollContainer/MarginContainer/Pages/Page_Audio/Grid/HSlider_SFX
@onready var btn_focus_mute = $MarginContainer/HBoxContainer/ScrollContainer/MarginContainer/Pages/Page_Audio/Grid/CheckBox_FocusMute

# Controls
@onready var btn_mouse = $MarginContainer/HBoxContainer/ScrollContainer/MarginContainer/Pages/Page_Controls/Grid/CheckBox_Mouse
@onready var btn_bind_up = $MarginContainer/HBoxContainer/ScrollContainer/MarginContainer/Pages/Page_Controls/Grid/Btn_Bind_Up
@onready var btn_bind_down = $MarginContainer/HBoxContainer/ScrollContainer/MarginContainer/Pages/Page_Controls/Grid/Btn_Bind_Down
@onready var btn_bind_left = $MarginContainer/HBoxContainer/ScrollContainer/MarginContainer/Pages/Page_Controls/Grid/Btn_Bind_Left
@onready var btn_bind_right = $MarginContainer/HBoxContainer/ScrollContainer/MarginContainer/Pages/Page_Controls/Grid/Btn_Bind_Right
@onready var btn_bind_interact = $MarginContainer/HBoxContainer/ScrollContainer/MarginContainer/Pages/Page_Controls/Grid/Btn_Bind_Interact
@onready var btn_bind_pause = $MarginContainer/HBoxContainer/ScrollContainer/MarginContainer/Pages/Page_Controls/Grid/Btn_Bind_Pause

# Gameplay
@onready var btn_dmg = $MarginContainer/HBoxContainer/ScrollContainer/MarginContainer/Pages/Page_Gameplay/Grid/CheckBox_Dmg
@onready var btn_particles = $MarginContainer/HBoxContainer/ScrollContainer/MarginContainer/Pages/Page_Gameplay/Grid/CheckBox_Particles
@onready var btn_skip_fade = $MarginContainer/HBoxContainer/ScrollContainer/MarginContainer/Pages/Page_Gameplay/Grid/CheckBox_Skip

@onready var save_feedback_label = $SaveFeedback

var is_overlay: bool = false

# Variable für das Keybinding System
var current_action_to_bind: String = ""

func _ready():
	# --- 1. WERTE INS UI LADEN ---
	if opt_window: opt_window.selected = 1 if SettingsManager.fullscreen else 0
	if opt_resolution: opt_resolution.selected = SettingsManager.resolution_index
	if btn_vsync: btn_vsync.button_pressed = SettingsManager.vsync_enabled
	if opt_fps: opt_fps.selected = SettingsManager.fps_limit_index
	if btn_show_fps: opt_fps.selected = SettingsManager.show_fps
	
	if slider_master: slider_master.value = SettingsManager.master_volume
	if slider_music: slider_music.value = SettingsManager.music_volume
	if slider_sfx: slider_sfx.value = SettingsManager.sfx_volume
	if btn_focus_mute: btn_focus_mute.button_pressed = SettingsManager.mute_on_focus_loss
	
	if btn_mouse: btn_mouse.button_pressed = SettingsManager.mouse_movement
	_update_keybind_buttons_text() # Lädt die Tasten-Namen auf die Knöpfe
	
	if btn_dmg: btn_dmg.button_pressed = SettingsManager.show_damage_numbers
	if btn_particles: btn_particles.button_pressed = SettingsManager.reduce_particles
	if btn_skip_fade: btn_skip_fade.button_pressed = SettingsManager.skip_transitions
	
	_update_resolution_dropdown_state()
	
	# --- 2. SIGNALE VERBINDEN ---
	if opt_window: opt_window.item_selected.connect(_on_window_selected)
	if opt_resolution: opt_resolution.item_selected.connect(_on_resolution_selected)
	if btn_vsync: btn_vsync.toggled.connect(_on_vsync_toggled)
	if opt_fps: opt_fps.item_selected.connect(_on_fps_selected)
	if btn_show_fps: btn_show_fps.toggled.connect(_on_fps_toggled)
	
	if slider_master: slider_master.value_changed.connect(_on_master_changed)
	if slider_music: slider_music.value_changed.connect(_on_music_changed)
	if slider_sfx: slider_sfx.value_changed.connect(_on_sfx_changed)
	if btn_focus_mute: btn_focus_mute.toggled.connect(_on_focus_mute_toggled)
	
	if btn_mouse: btn_mouse.toggled.connect(_on_mouse_toggled)
	
	# Keybind Buttons verbinden
	if btn_bind_up: btn_bind_up.pressed.connect(_on_bind_pressed.bind("move_up", btn_bind_up))
	if btn_bind_down: btn_bind_down.pressed.connect(_on_bind_pressed.bind("move_down", btn_bind_down))
	if btn_bind_left: btn_bind_left.pressed.connect(_on_bind_pressed.bind("move_left", btn_bind_left))
	if btn_bind_right: btn_bind_right.pressed.connect(_on_bind_pressed.bind("move_right", btn_bind_right))
	if btn_bind_interact: btn_bind_interact.pressed.connect(_on_bind_pressed.bind("interact", btn_bind_interact))
	if btn_bind_pause: btn_bind_pause.pressed.connect(_on_bind_pressed.bind("pause", btn_bind_pause))
	
	if btn_dmg: btn_dmg.toggled.connect(_on_dmg_toggled)
	if btn_particles: btn_particles.toggled.connect(_on_particles_toggled)
	if btn_skip_fade: btn_skip_fade.toggled.connect(_on_skip_transitions_toggled)
	
	show_page(page_display)

func show_save_feedback():
	if not save_feedback_label: return
	var tween = create_tween()
	save_feedback_label.modulate.a = 1.0 
	tween.tween_property(save_feedback_label, "modulate:a", 0.0, 0.5).set_delay(1.0)

# --- TAB LOGIC ---
func show_page(active_page):
	if page_display: page_display.hide()
	if page_audio: page_audio.hide()
	if page_controls: page_controls.hide()
	if page_gameplay: page_gameplay.hide()
	if active_page: active_page.show()

func _on_button_display_pressed(): show_page(page_display)
func _on_button_audio_pressed(): show_page(page_audio)
func _on_button_controls_pressed(): show_page(page_controls)
func _on_button_gameplay_pressed(): show_page(page_gameplay)

# ==========================================
# EINSTELLUNGEN - LOGIK
# ==========================================

# --- DISPLAY SETTINGS ---
func _on_window_selected(index: int):
	SettingsManager.fullscreen = (index == 1)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if SettingsManager.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	_update_resolution_dropdown_state()
	SettingsManager.save_settings()
	show_save_feedback()

func _update_resolution_dropdown_state():
	if opt_resolution: opt_resolution.disabled = SettingsManager.fullscreen

func _on_resolution_selected(index: int):
	SettingsManager.resolution_index = index
	match index:
		0: DisplayServer.window_set_size(Vector2i(1920, 1080))
		1: DisplayServer.window_set_size(Vector2i(1280, 720))
		2: DisplayServer.window_set_size(Vector2i(2560, 1440))
		3: DisplayServer.window_set_size(Vector2i(3840, 2160))
	SettingsManager.save_settings()
	show_save_feedback()

func _on_vsync_toggled(toggled_on: bool):
	SettingsManager.vsync_enabled = toggled_on
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if toggled_on else DisplayServer.VSYNC_DISABLED)
	SettingsManager.save_settings()
	show_save_feedback()

func _on_fps_selected(index: int):
	SettingsManager.fps_limit_index = index
	match index:
		0: Engine.max_fps = 30
		1: Engine.max_fps = 60
		2: Engine.max_fps = 90
		3: Engine.max_fps = 120
		4: Engine.max_fps = 144
		5: Engine.max_fps = 240
		6: Engine.max_fps = 0
	SettingsManager.save_settings()
	show_save_feedback()
	
func _on_fps_toggled(toggled_on: bool):
	SettingsManager.show_fps = toggled_on
	SettingsManager.save_settings()
	show_save_feedback()

# --- AUDIO SETTINGS ---
func _on_master_changed(value: float):
	SettingsManager.master_volume = value
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))
	SettingsManager.save_settings()
	show_save_feedback()

func _on_music_changed(value: float):
	SettingsManager.music_volume = value
	var bus_idx = AudioServer.get_bus_index("Music")
	if bus_idx != -1: AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
	SettingsManager.save_settings()

func _on_sfx_changed(value: float):
	SettingsManager.sfx_volume = value
	var bus_idx = AudioServer.get_bus_index("SFX")
	if bus_idx != -1: AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
	SettingsManager.save_settings()

func _on_focus_mute_toggled(toggled_on: bool):
	SettingsManager.mute_on_focus_loss = toggled_on
	SettingsManager.save_settings()
	show_save_feedback()

# --- GAMEPLAY SETTINGS ---
func _on_dmg_toggled(toggled_on: bool):
	SettingsManager.show_damage_numbers = toggled_on
	SettingsManager.save_settings()
	show_save_feedback()

func _on_particles_toggled(toggled_on: bool):
	SettingsManager.reduce_particles = toggled_on
	SettingsManager.save_settings()
	show_save_feedback()
	
func _on_skip_transitions_toggled(toggled_on: bool):
	SettingsManager.skip_transitions = toggled_on
	if has_node("/root/SceneChanger"):
		SceneChanger.skip_transitions = toggled_on
		SettingsManager.save_settings()
	show_save_feedback()

# ==========================================
# CONTROLS / KEYBINDING SYSTEM
# ==========================================
func _on_mouse_toggled(toggled_on: bool):
	SettingsManager.mouse_movement = toggled_on
	SettingsManager.save_settings()
	show_save_feedback()

func _update_keybind_buttons_text():
	# Holt sich die als String formatierte Taste aus dem SettingsManager
	if btn_bind_up: btn_bind_up.text = OS.get_keycode_string(SettingsManager.keybindings["move_up"])
	if btn_bind_down: btn_bind_down.text = OS.get_keycode_string(SettingsManager.keybindings["move_down"])
	if btn_bind_left: btn_bind_left.text = OS.get_keycode_string(SettingsManager.keybindings["move_left"])
	if btn_bind_right: btn_bind_right.text = OS.get_keycode_string(SettingsManager.keybindings["move_right"])
	if btn_bind_interact: btn_bind_interact.text = OS.get_keycode_string(SettingsManager.keybindings["interact"])
	if btn_bind_pause: btn_bind_pause.text = OS.get_keycode_string(SettingsManager.keybindings["pause"])

# Wird aufgerufen, wenn man auf einen Tasten-Button (z.B. "W") klickt
func _on_bind_pressed(action_name: String, button: Button):
	current_action_to_bind = action_name
	button.text = "..." # Zeigt an, dass das Spiel wartet

# Godot interne Funktion, die jeden Tastendruck abfängt
func _input(event):
	# Wenn wir gerade auf eine Taste warten UND es eine Tastatur-Taste ist...
	if current_action_to_bind != "" and event is InputEventKey and event.pressed:
		# 1. Speichere die neue Taste im Manager
		SettingsManager.keybindings[current_action_to_bind] = event.keycode
		# 2. Aktualisiere sofort das Godot Input Map System (via Manager)
		SettingsManager.apply_settings()
		SettingsManager.save_settings()
		# 3. Update die Text-Labels auf den Buttons
		_update_keybind_buttons_text()
		show_save_feedback()
		
		# Beende den Warte-Modus
		current_action_to_bind = ""
		# Verhindere, dass dieser Tastendruck noch woanders im Menü etwas auslöst
		get_viewport().set_input_as_handled()
