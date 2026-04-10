extends GdUnitTestSuite


func before_test():
	pass


func test_initial_health():
	var health = preload("res://main/entities/health.gd").new()
	health.max_health = 150

	health._ready()

	assert_that(health.current_health).is_equal(150)


func test_take_damage_reduces_health():
	var health = preload("res://main/entities/health.gd").new()
	health.max_health = 100
	health._ready()

	health.take_damage(30)

	assert_that(health.current_health).is_equal(70)


func test_health_does_not_go_below_zero():
	var health = preload("res://main/entities/health.gd").new()
	health.max_health = 50
	health._ready()

	health.take_damage(100)

	assert_that(health.current_health).is_equal(0)


func test_died_signal_emitted():
	var health = preload("res://main/entities/health.gd").new()
	health.max_health = 50
	health._ready()

	var signal_was_emitted = false
	health.died.connect(func(): signal_was_emitted = true)

	health.take_damage(100)

	assert_that(signal_was_emitted).is_true()
