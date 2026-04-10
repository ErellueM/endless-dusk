extends GdUnitTestSuite

var entity: Node2D


func before_test():
	# Scene laden
	entity = preload("res://main/entities/entity.tscn").instantiate()
	add_child(entity)
	await get_tree().process_frame


func after_test():
	if entity and is_instance_valid(entity):
		entity.queue_free()


func test_health_node_is_assigned():
	assert_that(entity.health).is_not_null()


func test_died_signal_connected():
	var health = entity.health

	var called := false
	health.died.connect(func(): called = true)

	health.emit_signal("died")

	assert_that(called).is_true()


func test_entity_is_freed_on_death():
	entity.health.emit_signal("died")

	await get_tree().process_frame

	assert_that(entity.is_queued_for_deletion()).is_true()
