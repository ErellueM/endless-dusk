extends GdUnitTestSuite

var audio_manager

func before_test():
	var script = load("res://main/global/audio_manager.gd")
	audio_manager = AudioStreamPlayer.new()
	audio_manager.set_script(script)
	add_child(audio_manager)
	await get_tree().process_frame

func after_test():
	if audio_manager and is_instance_valid(audio_manager):
		audio_manager.queue_free()

func test_play_music():
	var mock_stream = AudioStreamWAV.new()
	audio_manager.play_music(mock_stream)
	
	assert_that(audio_manager.stream).is_equal(mock_stream)
	assert_that(audio_manager.playing).is_true()

func test_stop_music():
	var mock_stream = AudioStreamWAV.new()
	audio_manager.play_music(mock_stream)
	audio_manager.stop_music()
	
	assert_that(audio_manager.playing).is_false()
