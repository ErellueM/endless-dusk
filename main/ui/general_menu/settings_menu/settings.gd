extends Node2D

@onready var master_bus = AudioServer.get_bus_index("Master")

# HIER DEINE PFADE ANPASSEN:
@onready var slider_volume = $CanvasLayer/VBoxContainer/HBoxContainer/HSlider
@onready var btn_mute = $CanvasLayer/VBoxContainer/HBoxContainer3/CheckButton
@onready var btn_vsync = $CanvasLayer/VBoxContainer/HBoxContainer2/VSync
@onready var btn_skip_fade = $CanvasLayer/VBoxContainer/HBoxContainer4/SkipTransitionsCheck

# Kommentiere diese ein und passe den Pfad an, wenn du die UI-Elemente erstellt hast:
# @onready var btn_fullscreen = $CanvasLayer/VBoxContainer/.../FullscreenCheck
# 

func _ready():
	# UI beim Öffnen auf die aktuell geladenen globalen Settings setzen
	if slider_volume:
		slider_volume.value = SettingsManager.master_volume
	if btn_mute:
		btn_mute.button_pressed = !SettingsManager.is_muted
	if btn_vsync:
		btn_vsync.button_pressed = SettingsManager.vsync_enabled
	if btn_skip_fade:
		btn_skip_fade.button_pressed = SettingsManager.skip_transitions
	# if btn_fullscreen:
	# 	btn_fullscreen.button_pressed = SettingsManager.fullscreen
	

func _on_h_slider_value_changed(value: float):
	SettingsManager.master_volume = value
	var db_value = linear_to_db(value)
	AudioServer.set_bus_volume_db(master_bus, db_value)
	
	if value <= 0.05:
		SettingsManager.is_muted = true
		AudioServer.set_bus_mute(master_bus, true)
		if btn_mute:
			btn_mute.button_pressed = false
	else:
		if AudioServer.is_bus_mute(master_bus):
			SettingsManager.is_muted = false
			AudioServer.set_bus_mute(master_bus, false)
			if btn_mute:
				btn_mute.button_pressed = true
				
	SettingsManager.save_settings()

func _on_check_button_toggled(toggled_on: bool):
	SettingsManager.is_muted = !toggled_on
	AudioServer.set_bus_mute(master_bus, !toggled_on)
	SettingsManager.save_settings()

func _on_v_sync_toggled(toggled_on: bool):
	SettingsManager.vsync_enabled = toggled_on
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	SettingsManager.save_settings()

func _on_fullscreen_check_toggled(toggled_on: bool):
	SettingsManager.fullscreen = toggled_on
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	SettingsManager.save_settings()

func _on_skip_transitions_toggled(toggled_on: bool):
	SettingsManager.skip_transitions = toggled_on
	if has_node("/root/SceneChanger"):
		SceneChanger.skip_transitions = toggled_on
	SettingsManager.save_settings()

func _on_button_back_pressed():
	# Geht dorthin zurück, wo du herkamst (Main Menu oder Pause Menü)
	SceneChanger.go_back()
