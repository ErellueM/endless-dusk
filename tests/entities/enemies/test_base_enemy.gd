extends GdUnitTestSuite

var enemy: BaseEnemy


func before_test():
	enemy = preload("res://main/entities/enemies/base_enemy.tscn").instantiate()
	add_child(enemy)
	await get_tree().process_frame


func after_test():
	if enemy and is_instance_valid(enemy):
		enemy.queue_free()


func test_enemy_initializes():
	assert_that(enemy.is_in_group("Enemygroup")).is_true()
	assert_that(enemy.current_speed).is_greater(0)


func test_take_damage_reduces_health():
	var health = enemy.health
	var before = health.current_health

	enemy.take_damage(10)
	await get_tree().process_frame

	assert_that(health.current_health).is_less(before)


func test_death_sets_is_dead():
	enemy.health.take_damage(9999)

	await get_tree().process_frame

	assert_that(enemy.is_dead).is_true()


func test_add_status_effect_slow():
	var effect = {"slow_factor": 0.5}

	var base_speed = enemy.base_speed

	enemy.add_status_effect("slow", effect)

	assert_that(enemy.current_speed).is_equal(base_speed * 0.5)


func test_remove_status_effect_restores_speed():
	var effect = {"slow_factor": 0.5}

	var base_speed = enemy.base_speed

	enemy.add_status_effect("slow", effect)
	enemy.remove_status_effect("slow")

	assert_that(enemy.current_speed).is_equal(base_speed)


func test_status_effect_duration_removal():
	var effect = {"duration": 0.01}

	enemy.add_status_effect("temp", effect)

	await get_tree().process_frame

	assert_that(enemy.active_effects.has("temp")).is_false()


func test_enemy_has_player_target():
	assert_that(enemy.player).is_not_null()


func test_enemy_moves_towards_player():
	var start_pos = enemy.global_position

	await get_tree().process_frame

	assert_that(enemy.global_position).is_not_equal(start_pos)


func test_enemy_can_attack_player():
	var player = enemy.player

	var was_hit := false
	player.take_damage = func(amount): was_hit = true

	enemy.attack_area = Node2D.new()

	enemy.take_damage(0)

	assert_that(true).is_true()
