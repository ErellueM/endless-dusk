extends GdUnitTestSuite

var candle

func before_test():
	var script = load("res://main/environments/lightSources/candle_2.gd")
	candle = Node2D.new()
	candle.set_script(script)
	
	# Mock children
	var flame = AnimatedSprite2D.new()
	var light = PointLight2D.new()
	candle.add_child(flame)
	candle.add_child(light)
	candle.flame = flame
	candle.light = light
	
	add_child(candle)
	await get_tree().process_frame

func after_test():
	if candle and is_instance_valid(candle):
		candle.queue_free()

func test_process_updates_time():
	var initial_t = candle.t
	await get_tree().process_frame
	await get_tree().process_frame
	assert_that(candle.t).is_greater(initial_t)

func test_light_energy_is_calculated():
	await get_tree().process_frame
	assert_that(candle.light.energy).is_not_equal(0.0)
