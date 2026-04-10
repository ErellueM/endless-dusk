extends GdUnitTestSuite


func before_test():
	Global.reset_run_stats()


func test_initial_values():
	assert_that(Global.run_total_kills).is_equal(0)


func test_register_kill():
	Global.register_kill("slime")
	assert_that(Global.run_total_kills).is_equal(1)
	assert_that(Global.run_kills_by_type["slime"]).is_equal(1)


func test_register_multiple_kills():
	Global.register_kill("slime")
	Global.register_kill("bat")
	Global.register_kill("bat")

	assert_that(Global.run_total_kills).is_equal(3)
	assert_that(Global.run_kills_by_type["bat"]).is_equal(2)


func test_reset_run_stats():
	Global.register_kill("slime")
	Global.reset_run_stats()

	assert_that(Global.run_total_kills).is_equal(0)
	assert_that(Global.run_kills_by_type.is_empty()).is_true()
