extends GdUnitTestSuite


class TestEnemy:
	extends CharacterBody2D
	var received_damage: float = 0.0

	func take_damage(amount: float) -> void:
		received_damage += amount


var weapon: AuraWeapon
var aura_area: Area2D
var enemy: TestEnemy


func before_test() -> void:
	weapon = AuraWeapon.new()
	aura_area = Area2D.new()
	aura_area.name = "AuraArea"
	aura_area.monitoring = true
	var aura_shape := CollisionShape2D.new()
	aura_shape.shape = CircleShape2D.new()
	aura_shape.shape.radius = 64.0
	aura_area.add_child(aura_shape)
	weapon.add_child(aura_area)
	add_child(weapon)
	await get_tree().process_frame


func after_test() -> void:
	if enemy and is_instance_valid(enemy):
		enemy.queue_free()
	if weapon and is_instance_valid(weapon):
		weapon.queue_free()


func test_attack_deals_damage_to_overlapping_enemy_and_returns_true() -> void:
	enemy = TestEnemy.new()
	var enemy_shape := CollisionShape2D.new()
	enemy_shape.shape = CircleShape2D.new()
	enemy_shape.shape.radius = 8.0
	enemy.add_child(enemy_shape)
	enemy.add_to_group("Enemygroup")
	weapon.add_child(enemy)
	enemy.global_position = weapon.global_position
	await get_tree().physics_frame
	await get_tree().physics_frame
	var result = weapon.attack()

	assert_that(enemy.received_damage).is_equal(weapon.get_actual_damage())
	assert_that(result).is_true()


func test_tick_effect() -> void:
	pass


func test_enter_effect() -> void:
	pass


func test_exit_effect() -> void:
	pass
