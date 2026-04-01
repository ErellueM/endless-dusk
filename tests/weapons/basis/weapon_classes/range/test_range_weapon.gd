extends GdUnitTestSuite

class EnemyDouble:
	extends Node2D
	var is_dead: bool = false

class ProjectileDouble:
	extends Node2D
	var damage: float = 0.0
	var velocity: Vector2 = Vector2.ZERO
	var weapon_ref: Node = null

var weapon: RangeWeapon
var spawned_enemies: Array[Node2D] = []

func before_test() -> void:
	weapon = RangeWeapon.new()
	add_child(weapon)
	await get_tree().process_frame

func after_test() -> void:
	for enemy in spawned_enemies:
		if enemy and is_instance_valid(enemy):
			enemy.queue_free()
	spawned_enemies.clear()
	if weapon and is_instance_valid(weapon):
		weapon.queue_free()

func _create_enemy(position: Vector2, dead: bool = false) -> EnemyDouble:
	var enemy := EnemyDouble.new()
	enemy.global_position = position
	enemy.is_dead = dead
	enemy.add_to_group("Enemygroup")
	add_child(enemy)
	spawned_enemies.append(enemy)
	return enemy

func _make_projectile_scene() -> PackedScene:
	var projectile_scene := PackedScene.new()
	var projectile := ProjectileDouble.new()
	projectile_scene.pack(projectile)
	projectile.free()
	return projectile_scene

func test_attack_returns_false_without_enemy() -> void:
	weapon.projectile_scene = _make_projectile_scene()
	var result := weapon.attack()
	assert_that(result).is_false()
	assert_that(weapon.get_child_count()).is_equal(0)

func test_get_nearest_enemy_returns_closest_living_enemy() -> void:
	var close_alive := _create_enemy(Vector2(50, 0), false)
	_create_enemy(Vector2(25, 0), true)

	var nearest := weapon.get_nearest_enemy()
	assert_that(nearest).is_equal(close_alive)
	
func test_get_nearest_enemy_returns_null_if_no_living_enemies() -> void:
	_create_enemy(Vector2(50, 0), true)
	_create_enemy(Vector2(25, 0), true)

	var nearest := weapon.get_nearest_enemy()
	assert_that(nearest).is_null()

func test_get_nearest_enemy_returns_null_if_enemies_out_of_range() -> void:
	_create_enemy(Vector2(weapon.get_actual_range() +1, 0), false)
	var nearest := weapon.get_nearest_enemy()
	assert_that(nearest).is_null()

func test_shoot_at_initializes_projectile_fields() -> void:
	var target := _create_enemy(Vector2(100, 0), false)
	weapon.spawn_offset = 25.0
	weapon.projectile_speed = 300.0
	weapon.projectile_scene = _make_projectile_scene()

	weapon.shoot_at(target)

	assert_that(weapon.get_child_count()).is_equal(1)
	var projectile := weapon.get_child(0) as ProjectileDouble
	var expected_direction := (target.global_position - weapon.global_position).normalized()

	assert_that(projectile.damage).is_equal(weapon.get_actual_damage())
	assert_that(projectile.weapon_ref).is_equal(weapon)
	assert_that(projectile.velocity).is_equal(expected_direction * weapon.projectile_speed)
	assert_that(projectile.global_position).is_equal(
		weapon.global_position + expected_direction * weapon.spawn_offset
	)
	assert_that(projectile.scale).is_equal(
		Vector2(weapon.get_actual_area(), weapon.get_actual_area())
	)

func test_shoot_at_does_not_spawn_projectile_without_scene() -> void:
	var target := _create_enemy(Vector2(100, 0), false)
	weapon.projectile_scene = null

	weapon.shoot_at(target)

	assert_that(weapon.get_child_count()).is_equal(0)
