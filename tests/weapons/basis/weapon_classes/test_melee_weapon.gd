extends GdUnitTestSuite


class TestEnemy:
	extends CharacterBody2D
	var received_damage: float = 0.0

	func take_damage(amount: float) -> void:
		received_damage += amount


var weapon: MeleeWeapon
var hitbox: Area2D
var anim_player: AnimationPlayer


func before_test() -> void:
	anim_player = AnimationPlayer.new()
	anim_player.name = "AnimationPlayer"
	weapon = MeleeWeapon.new()
	hitbox = Area2D.new()
	hitbox.name = "HitboxArea"
	weapon.add_child(hitbox)
	weapon.add_child(anim_player)
	add_child(weapon)
	await get_tree().process_frame


func test_attack_returns_false_without_animation_and_true_with_animation() -> void:
	var lib := AnimationLibrary.new()
	lib.add_animation("swing", Animation.new())

	var result_without_animation = await weapon.attack()

	anim_player.add_animation_library("", lib)
	var result_with_animation = await weapon.attack()

	assert_that(result_without_animation).is_false()
	assert_that(result_with_animation).is_true()


func test_on_hitbox_body_entered_deals_damage_to_enemy() -> void:
	var enemy = TestEnemy.new()
	enemy.add_to_group("Enemygroup")
	weapon._on_hitbox_body_entered(enemy)
	assert_that(enemy.received_damage).is_equal(weapon.base_damage)
	assert_that(weapon.total_damage_dealt).is_equal(weapon.base_damage)
