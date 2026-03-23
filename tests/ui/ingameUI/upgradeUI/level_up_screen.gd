extends GdUnitTestSuite

const SCENE_PATH = "res://main/ui/ingameUI/upgradeUI/LevelUpScreen.tscn"

# Ein einfacher Mock für den Spieler, damit die UI nicht abstürzt
class MockPlayer extends Node2D:
	var luck = 1.0
	var might = 1.0
	var speed = 100.0
	var health_component = {"max_health": 100.0, "current_health": 100.0}
	func _init():
		add_to_group("player")

func test_get_weight_with_luck_bonus():
	var runner = scene_runner(SCENE_PATH)
	var ui = runner.working_node()
	
	var common_item = {"rarity": "Common", "type": "stat"}
	var rare_item = {"rarity": "Rare", "type": "stat"}
	
	# Test bei Standard-Glück (1.0)
	assert_that(ui.get_weight(common_item, 1.0)).is_equal(70.0)
	assert_that(ui.get_weight(rare_item, 1.0)).is_equal(25.0)
	
	# Test bei hohem Glück (2.0) -> Rare sollte doppelt so wahrscheinlich sein
	assert_that(ui.get_weight(rare_item, 2.0)).is_equal(50.0)

func test_debug_force_weapons_weight():
	var runner = scene_runner(SCENE_PATH)
	var ui = runner.working_node()
	
	var weapon_item = {"rarity": "Common", "type": "new_weapon"}
	
	# Normaler Modus
	ui.debug_force_weapons = false
	var normal_weight = ui.get_weight(weapon_item, 1.0)
	assert_that(normal_weight).is_equal(70.0 * ui.weapon_weight_multiplier)
	
	# Cheat Modus aktiv
	ui.debug_force_weapons = true
	assert_that(ui.get_weight(weapon_item, 1.0)).is_equal(99999.0)

func test_apply_stat_upgrade_single_and_multiple():
	var runner = scene_runner(SCENE_PATH)
	var ui = runner.working_node()
	var mock_player = auto_free(MockPlayer.new())
	
	# 1. Einfaches Upgrade (Might)
	var simple_upgrade = {"stats": [{"key": "might", "amount": 0.1}]}
	ui.apply_stat_upgrade(mock_player, simple_upgrade)
	assert_that(mock_player.might).is_equal(1.1)
	
	# 2. Komplexes Upgrade (Brute Force: +Might, -Speed)
	# Hinweis: In deinem Mock-Player müssen die Variablen existieren!
	var complex_upgrade = {"stats": [
		{"key": "might", "amount": 0.25},
		{"key": "speed", "amount": -5.0}
	]}
	var old_might = mock_player.might
	var old_speed = mock_player.speed
	
	ui.apply_stat_upgrade(mock_player, complex_upgrade)
	
	assert_that(mock_player.might).is_equal(old_might + 0.25)
	assert_that(mock_player.speed).is_equal(old_speed - 5.0)

func test_card_generation_clears_old_cards():
	var runner = scene_runner(SCENE_PATH)
	var container = runner.find_child("CardContainer")
	
	# Wir fügen manuell Dummy-Karten hinzu
	for i in 5:
		container.add_child(Node.new())
	
	assert_that(container.get_child_count()).is_equal(5)
	
	# Trigger Generierung (ohne Player wird der Pool nur aus stats bestehen)
	runner.invoke("generate_cards")
	
	# Die alten 5 müssen weg sein, maximal 3 neue (da Optionen-Limit = 3)
	assert_that(container.get_child_count()).is_less_than(4)

func test_health_upgrade_caps_correctly():
	var runner = scene_runner(SCENE_PATH)
	var ui = runner.working_node()
	var mock_player = auto_free(MockPlayer.new())
	
	# Wir simulieren ein Legendary Health Upgrade (-20 Max Health)
	# Aktuell: 100/100
	var health_down = {"stats": [{"key": "max_health", "amount": -20.0}]}
	ui.apply_stat_upgrade(mock_player, health_down)
	
	assert_that(mock_player.health_component.max_health).is_equal(80.0)
	# Aktuelle HP sollte mit schrumpfen oder gecappt werden
	assert_that(mock_player.health_component.current_health).is_equal(80.0)
