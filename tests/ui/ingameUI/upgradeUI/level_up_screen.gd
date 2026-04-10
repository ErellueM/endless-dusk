extends GdUnitTestSuite

const SCENE_PATH = "res://main/ui/ingameUI/upgradeUI/LevelUpScreen.tscn"


class MockPlayer:
	extends Node2D
	var luck = 1.0
	var might = 1.0
	var speed = 100.0
	var health_component = {"max_health": 100.0, "current_health": 100.0}

	func _init():
		add_to_group("player")


func test_get_weight_with_luck_bonus():
	var runner = scene_runner(SCENE_PATH)
	var ui = runner.scene()

	var common_item = {"rarity": "Common", "type": "stat"}
	var rare_item = {"rarity": "Rare", "type": "stat"}

	assert_that(ui.get_weight(common_item, 1.0)).is_equal(70.0)
	assert_that(ui.get_weight(rare_item, 1.0)).is_equal(25.0)
	assert_that(ui.get_weight(rare_item, 2.0)).is_equal(50.0)


func test_debug_force_weapons_weight():
	var runner = scene_runner(SCENE_PATH)
	var ui = runner.scene()

	var weapon_item = {"rarity": "Common", "type": "new_weapon"}

	ui.debug_force_weapons = false
	var normal_weight = ui.get_weight(weapon_item, 1.0)
	assert_that(normal_weight).is_equal(70.0 * ui.weapon_weight_multiplier)

	ui.debug_force_weapons = true
	assert_that(ui.get_weight(weapon_item, 1.0)).is_equal(99999.0)


func test_apply_stat_upgrade_single_and_multiple():
	var runner = scene_runner(SCENE_PATH)
	var ui = runner.scene()
	var mock_player = auto_free(MockPlayer.new())

	var simple_upgrade = {"stats": [{"key": "might", "amount": 0.1}]}
	ui.apply_stat_upgrade(mock_player, simple_upgrade)
	assert_that(mock_player.might).is_equal(1.1)

	var complex_upgrade = {
		"stats": [{"key": "might", "amount": 0.25}, {"key": "speed", "amount": -5.0}]
	}
	var old_might = mock_player.might
	var old_speed = mock_player.speed

	ui.apply_stat_upgrade(mock_player, complex_upgrade)

	assert_that(mock_player.might).is_equal(old_might + 0.25)
	assert_that(mock_player.speed).is_equal(old_speed - 5.0)


func test_card_generation_clears_old_cards():
	var runner = scene_runner(SCENE_PATH)
	var container = runner.find_child("CardContainer")

	# 1. Container leeren
	for child in container.get_children():
		child.free()

	# 2. 5 Dummy-Nodes hinzufügen
	for i in 5:
		container.add_child(Node.new())
	assert_that(container.get_child_count()).is_equal(5)

	# 3. Generierung triggern
	runner.invoke("generate_cards")

	# 4. Dem Engine-Loop Zeit geben, queue_free auszuführen
	await runner.simulate_frames(1)

	# 5. Check: 8 wäre falsch, es sollten (bei 3 neuen Karten) genau 3 sein
	assert_that(container.get_child_count()).is_less(4)


func test_health_upgrade_caps_correctly():
	var runner = scene_runner(SCENE_PATH)
	var ui = runner.scene()
	var mock_player = auto_free(MockPlayer.new())

	var health_down = {"stats": [{"key": "max_health", "amount": -20.0}]}
	ui.apply_stat_upgrade(mock_player, health_down)

	assert_that(mock_player.health_component.max_health).is_equal(80.0)
	assert_that(mock_player.health_component.current_health).is_equal(80.0)
