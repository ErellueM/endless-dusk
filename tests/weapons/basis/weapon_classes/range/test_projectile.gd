extends GdUnitTestSuite

class EnemyDouble:
	extends Node2D
	var is_dead: bool = false
	var health_component: Node = null
	var damage_taken: float = 0.0
	var status_effects: Dictionary = {}

	func take_damage(amount: float) -> void:
		damage_taken += amount

	func add_status_effect(effect_name: String, effect_data: Dictionary) -> void:
		status_effects[effect_name] = effect_data

class WeaponDouble:
	extends Node2D
	var total_damage_dealt: float = 0.0
	var applies_poison: bool = false

	func add_damage_stat(amount: float) -> void:
		total_damage_dealt += amount

var projectile: Area2D
var weapon: WeaponDouble
var enemy: EnemyDouble

func before_test() -> void:
	projectile = Area2D.new()
	projectile.script = load("res://main/weapons/basis/weapon_classes/range/projectile.gd")
	
	weapon = WeaponDouble.new()
	enemy = EnemyDouble.new()
	enemy.add_to_group("Enemygroup")
	
	add_child(projectile)
	add_child(weapon)
	add_child(enemy)
	await get_tree().process_frame

func after_test() -> void:
	if projectile and is_instance_valid(projectile):
		projectile.queue_free()
	if weapon and is_instance_valid(weapon):
		weapon.queue_free()
	if enemy and is_instance_valid(enemy):
		enemy.queue_free()

func test_physics_process_moves_projectile() -> void:
	projectile.velocity = Vector2(100, 0)
	projectile.global_position = Vector2.ZERO
	
	projectile._physics_process(0.1)
	
	assert_that(projectile.global_position).is_equal(Vector2(10, 0))

func test_physics_process_rotates_towards_velocity() -> void:
	projectile.velocity = Vector2(1, 0)
	projectile.rotation = 0.0
	
	projectile._physics_process(0.016)
	
	assert_that(projectile.rotation).is_equal(0.0)

func test_on_body_entered_deals_damage_to_enemy() -> void:
	projectile.damage = 25.0
	projectile.weapon_ref = weapon
	
	projectile._on_body_entered(enemy)
	
	assert_that(enemy.damage_taken).is_equal(25.0)

func test_on_body_entered_ignores_non_enemy_bodies() -> void:
	var other_body := Node2D.new()
	add_child(other_body)
	
	projectile.damage = 25.0
	projectile.weapon_ref = weapon
	projectile._on_body_entered(other_body)
	
	assert_that(enemy.damage_taken).is_equal(0.0)
	assert_that(weapon.total_damage_dealt).is_equal(0.0)
	other_body.queue_free()

func test_on_body_entered_destroys_projectile() -> void:
	projectile.damage = 10.0
	projectile.weapon_ref = weapon
	var projectile_ref := projectile
	
	projectile._on_body_entered(enemy)
	await get_tree().process_frame
	
	assert_that(is_instance_valid(projectile_ref)).is_false()

func test_on_body_entered_applies_poison_effect() -> void:
	weapon.applies_poison = true
	projectile.damage = 20.0
	projectile.weapon_ref = weapon
	
	projectile._on_body_entered(enemy)
	
	assert_that(enemy.status_effects.has("knife_poison")).is_true()
