# Pfad zu deiner StatsMenu.tscn
extends GdUnitTestSuite

const SCENE_PATH = "res://main/ui/ingameUI/pauseMenu.tscn"

# --- MOCK PLAYER ---
# Wir bauen einen Player, der alle vom Skript erwarteten Properties hat
class MockPlayer extends Node2D:
	var health_component = {"current_health": 50.0, "max_health": 100.0}
	var armor = 5.0
	var recovery = 1.0
	var might = 1.5      # +50%
	var area = 0.8       # -20%
	var cooldown_mult = 0.9 # -10% (Positiv für den Spieler)
	var speed = 150.0
	var luck = 1.2
	var magnet_mult = 1.1
	var growth = 1.0
	func _init(): add_to_group("player")

# --- MOCK WAFFE ---
class MockWeapon extends Node2D:
	var weapon_id = "phantom_glaive"
	var total_damage_dealt = 5000.0
	var level = 3
	var max_level = 5
	var is_utility = false
	func get_actual_damage(): return 25.0
	func get_upgrade_info(_lvl): return {"desc": "test", "rarity": "Common"}

# --- TESTS ---

func test_update_stats_math_and_colors():
	var runner = scene_runner(SCENE_PATH)
	var ui = runner.working_node()
	var player = auto_free(MockPlayer.new())
	
	# Global Stats resetten für sauberen Test
	Global.run_total_kills = 10
	
	# Stats Grid finden
	var stats_grid = runner.find_child("StatsGrid")
	
	ui.update_stats(player)
	
	# Wir prüfen, ob die Labels erzeugt wurden. 
	# Da es ein GridContainer ist, sind Name und Wert separate Kinder.
	# 1. Health (erstes Paar)
	var hp_label_val = stats_grid.get_child(1) as Label
	assert_that(hp_label_val.text).is_equal("50 / 100")
	
	# 4. Might (4. Paar -> Index 6 & 7)
	var might_label_val = stats_grid.get_child(7) as Label
	assert_that(might_label_val.text).is_equal("50%")
	assert_that(might_label_val.modulate).is_equal(Color.GREEN)
	
	# 6. Cooldown (6. Paar -> Index 10 & 11)
	# (0.9 - 1.0) * 100 = -10%
	var cd_label_val = stats_grid.get_child(11) as Label
	assert_that(cd_label_val.text).is_equal("-10%")
	assert_that(cd_label_val.modulate).is_equal(Color.GREEN) # Negativ ist gut bei CD!

func test_update_weapons_sorting_and_max_level():
	var runner = scene_runner(SCENE_PATH)
	var ui = runner.working_node()
	var player = auto_free(MockPlayer.new())
	
	# Mock Inventory bauen
	var inv = Node.new()
	inv.name = "WeaponInventory"
	player.add_child(inv)
	
	# Zwei Waffen hinzufügen: Eine schwache, eine starke
	var weak_w = auto_free(MockWeapon.new())
	weak_w.name = "WeakWeapon"
	weak_w.total_damage_dealt = 100.0
	inv.add_child(weak_w)
	
	var strong_w = auto_free(MockWeapon.new())
	strong_w.name = "StrongWeapon"
	strong_w.total_damage_dealt = 9999.0
	strong_w.level = 5 # MAX
	inv.add_child(strong_w)
	
	ui.update_weapons(player)
	
	var weapons_grid = runner.find_child("WeaponsGrid")
	
	# StrongWeapon muss oben sein (Index 0)
	var first_row = weapons_grid.get_child(0)
	# Wir suchen das RichTextLabel in der VBox der Zeile
	var rt_label = first_row.find_child("*", true, false) as RichTextLabel
	
	assert_that(rt_label.text).contains("Strong")
	assert_that(rt_label.text).contains("MAX") # Da Level 5/5

func test_format_huge_number():
	var runner = scene_runner(SCENE_PATH)
	var ui = runner.working_node()
	
	assert_that(ui.format_huge_number(950)).is_equal("950")
	assert_that(ui.format_huge_number(1500)).is_equal("1.5k")
	assert_that(ui.format_huge_number(2300000)).is_equal("2.3M")

func test_visibility_trigger():
	var runner = scene_runner(SCENE_PATH)
	var ui = runner.working_node()
	
	# Wir simulieren das Einblenden
	ui.visible = false
	ui.visible = true # Löst _on_visibility_changed aus
	
	# Das Control-Element muss jetzt sichtbar sein
	var content = runner.find_child("Control")
	assert_that(content.visible).is_true()
