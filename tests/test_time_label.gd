extends GdUnitTestSuite

var time_label

func before_test():
	var script = load("res://time_label.gd")
	time_label = Label.new()
	time_label.set_script(script)
	add_child(time_label)
	await get_tree().process_frame

func after_test():
	if time_label and is_instance_valid(time_label):
		time_label.queue_free()

func test_instantiation():
	assert_that(time_label).is_not_null()
	assert_that(time_label is Label).is_true()
