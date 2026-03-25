# Pfad zu deiner Settings-Szene anpassen
extends GdUnitTestSuite

const SCENE_PATH = "res://main/ui/general_menu/settings_menu/settings.tscn"

func test_initialization_sets_ui_correctly():
	var runner = scene_runner(SCENE_PATH)
	
	# Wir holen die Referenzen auf die UI-Elemente
	var slider = runner.find_child("HSlider") as HSlider
	var mute_button = runner.find_child("CheckButton") as CheckButton
	var vsync_button = runner.find_child("VSync") as CheckButton
	
	await runner.simulate_frames(1)
	
	# 1. Audio-Check
	var master_bus = AudioServer.get_bus_index("Master")
	var expected_val = db_to_linear(AudioServer.get_bus_volume_db(master_bus))
	assert_that(slider.value).is_equal(expected_val)
	assert_that(mute_button.button_pressed).is_equal(!AudioServer.is_bus_mute(master_bus))
	
	# 2. V-Sync Check (da du es in _ready erzwingst)
	assert_that(DisplayServer.window_get_vsync_mode()).is_equal(DisplayServer.VSYNC_ENABLED)
	assert_that(vsync_button.button_pressed).is_true()

func test_audio_slider_changes_volume():
	var runner = scene_runner(SCENE_PATH)
	var master_bus = AudioServer.get_bus_index("Master")
	
	# Wir simulieren das Schieben des Sliders auf 50%
	runner.invoke("_on_h_slider_value_changed", 0.5)
	
	var current_db = AudioServer.get_bus_volume_db(master_bus)
	assert_that(current_db).is_equal(linear_to_db(0.5))
	assert_that(AudioServer.is_bus_mute(master_bus)).is_false()

func test_audio_slider_low_value_mutes():
	var runner = scene_runner(SCENE_PATH)
	var mute_button = runner.find_child("CheckButton") as CheckButton
	
	# Slider auf fast 0 schieben (dein Schwellwert ist 0.05)
	runner.invoke("_on_h_slider_value_changed", 0.02)
	
	var master_bus = AudioServer.get_bus_index("Master")
	assert_that(AudioServer.is_bus_mute(master_bus)).is_true()
	assert_that(mute_button.button_pressed).is_false()

func test_mute_button_toggles_audio():
	var runner = scene_runner(SCENE_PATH)
	var master_bus = AudioServer.get_bus_index("Master")
	
	# Mute an
	runner.invoke("_on_check_button_toggled", false)
	assert_that(AudioServer.is_bus_mute(master_bus)).is_true()
	
	# Mute aus
	runner.invoke("_on_check_button_toggled", true)
	assert_that(AudioServer.is_bus_mute(master_bus)).is_false()

func test_vsync_toggle():
	var runner = scene_runner(SCENE_PATH)
	
	# V-Sync ausschalten
	runner.invoke("_on_v_sync_toggled", false)
	assert_that(DisplayServer.window_get_vsync_mode()).is_equal(DisplayServer.VSYNC_DISABLED)
	
	# V-Sync wieder einschalten
	runner.invoke("_on_v_sync_toggled", true)
	assert_that(DisplayServer.window_get_vsync_mode()).is_equal(DisplayServer.VSYNC_ENABLED)
