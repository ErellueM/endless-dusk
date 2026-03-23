extends Node2D

const SCENE_MAIN = "res://main/ui/general_menu/main_menu/main_menu.tscn"

@onready var master_bus = AudioServer.get_bus_index("Master")

func _ready():
	# 1. Audio-Initialisierung
	var current_vol_db = AudioServer.get_bus_volume_db(master_bus)
	$CanvasLayer/VBoxContainer/HBoxContainer/HSlider.value = db_to_linear(current_vol_db)
	$CanvasLayer/VBoxContainer/HBoxContainer3/CheckButton.button_pressed = !AudioServer.is_bus_mute(master_bus)
	
	# 2. V-Sync standardmäßig einschalten
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	# 3. UI-Checkbox auf "an" setzen (passend zum erzwungenen V-Sync)
	$CanvasLayer/VBoxContainer/HBoxContainer2/VSync.button_pressed = true

# SIGNAL: Vom Volume-Slider (HSlider)
# Signal: value_changed vom HSlider (Range 0 bis 1)
func _on_h_slider_value_changed(value: float):
	# Umwandlung von 0..1 in Dezibel (z.B. 1.0 -> 0dB, 0.5 -> -6dB)
	var db_value = linear_to_db(value)
	AudioServer.set_bus_volume_db(master_bus, db_value)
	
	# Kleiner Trick: Wenn der Slider ganz links ist, komplett muten
	if value <= 0.05:
		AudioServer.set_bus_mute(master_bus, true)
		$CanvasLayer/VBoxContainer/HBoxContainer3/CheckButton.button_pressed = false
	else:
		# Wenn wir schieben, soll der Ton auch angehen
		if AudioServer.is_bus_mute(master_bus):
			AudioServer.set_bus_mute(master_bus, false)
			$CanvasLayer/VBoxContainer/HBoxContainer3/CheckButton.button_pressed = true

# Signal: toggled vom CheckButton
func _on_check_button_toggled(toggled_on: bool):
	# toggled_on ist true, wenn der Button "an" ist. 
	# Wir muten also nur, wenn toggled_on false ist.
	AudioServer.set_bus_mute(master_bus, !toggled_on)

# SIGNAL: Von der V-Sync-Checkbox (toggled) - Muss im Editor verbunden werden!
func _on_v_sync_toggled(toggled_on: bool):
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		
# Zurück-Button
func _on_button_back_pressed():
	if ResourceLoader.exists(SCENE_MAIN):
		get_tree().change_scene_to_file(SCENE_MAIN)
	else:
		print("FEHLER: Zielszene nicht gefunden unter: ", SCENE_MAIN)

func _on_fullscreen_check_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.
