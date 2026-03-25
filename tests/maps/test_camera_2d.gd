extends GdUnitTestSuite

var cam: Camera2D
var target: Node2D

func before_test():
	var script = load("res://maps/camera_2d.gd")
	cam = Camera2D.new()
	cam.set_script(script)
	
	target = Node2D.new()
	target.global_position = Vector2(100, 100)
	
	add_child(cam)
	add_child(target)
	await get_tree().process_frame

func after_test():
	if cam and is_instance_valid(cam):
		cam.queue_free()
	if target and is_instance_valid(target):
		target.queue_free()

func test_follow_target():
	cam.target_node = target
	cam.smoothing_enabled = false
	await get_tree().process_frame
	
	assert_that(cam.global_position).is_equal(target.global_position)

func test_smoothing():
	cam.target_node = target
	cam.global_position = Vector2(0, 0)
	cam.smoothing_enabled = true
	cam.smoothing_speed = 5.0
	
	await get_tree().process_frame
	assert_that(cam.global_position.x).is_greater(0.0)
	assert_that(cam.global_position.x).is_less(100.0)
