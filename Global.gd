extends Node

var selected_character_scene: PackedScene = load(
	"res://main/entities/Characters/PlayableCharacter_01.tscn"
)
const SAVE_PATH = "user://savegame.cfg"

var unlocked_characters: Array = ["Soilder"]
var discovered_weapons: Array = []
var discovered_upgrades: Array = []
var unlocked_items: Array = []
var unlocked_achievements: Array = []

var total_runs_played: int = 0
var lifetime_damage_dealt: float = 0.0
var highest_level_reached: int = 1
var run_damage_dealt: float = 0.0

var highest_survival_time: float = 0.0
var total_time_played: float = 0.0

# --- RUN STATS ---
var run_total_kills: int = 0
var run_kills_by_type: Dictionary = {}
var achievements_this_run: Array = []
var run_upgrades: Dictionary = {}
var bosses_defeated_this_run: int = 0

# --- LIFETIME STATS ---
var lifetime_total_kills: int = 0
var lifetime_kills_by_type: Dictionary = {}

signal gold_changed(new_amount)

var total_gold_earned: int = 0
var gold: int = 0:
	set(value):
		if value > gold:
			total_gold_earned += (value - gold)
		gold = value
		gold_changed.emit(gold) 


func _ready():
	load_game()  # Lädt die Lifetime-Stats direkt beim Spielstart


func register_kill(enemy_name: String):
	run_total_kills += 1
	if run_kills_by_type.has(enemy_name):
		run_kills_by_type[enemy_name] += 1
	else:
		run_kills_by_type[enemy_name] = 1

	lifetime_total_kills += 1
	if lifetime_kills_by_type.has(enemy_name):
		lifetime_kills_by_type[enemy_name] += 1
	else:
		lifetime_kills_by_type[enemy_name] = 1

func discover_weapon(weapon_id: String):
	if not weapon_id in discovered_weapons:
		discovered_weapons.append(weapon_id)
		save_game()

func discover_upgrade(upgrade_name: String):
	if not upgrade_name in discovered_upgrades:
		discovered_upgrades.append(upgrade_name)
		save_game()

func unlock_item(item_id: String):
	if not item_id in unlocked_items:
		unlocked_items.append(item_id)
		save_game()

func unlock_achievement_manual(ach_id: String):
	if not unlocked_achievements.has(ach_id):
		unlocked_achievements.append(ach_id)
		achievements_this_run.append(ach_id)
		save_game()
		print("Manually Unlocked Achievement: ", ach_id)

func check_achievements():
	var newly_unlocked = false
	for ach_id in AchievementDatabase.achievements:
		if unlocked_achievements.has(ach_id): continue
		
		var data = AchievementDatabase.achievements[ach_id]
		var is_done = false
		match data["type"]:
			"time":   if highest_survival_time >= data["target"]: is_done = true
			"kills":  if lifetime_total_kills >= data["target"]: is_done = true
			"damage": if lifetime_damage_dealt >= data["target"]: is_done = true
			"level":  if highest_level_reached >= data["target"]: is_done = true
			"gold":   if total_gold_earned >= data["target"]: is_done = true
			"runs":   if total_runs_played >= data["target"]: is_done = true
		
		if is_done:
			unlocked_achievements.append(ach_id)
			achievements_this_run.append(ach_id)
			newly_unlocked = true
			print("Unlocked: ", data["name"])
			
	if newly_unlocked: save_game()

func add_run_upgrade(upgrade_name: String):
	if run_upgrades.has(upgrade_name):
		run_upgrades[upgrade_name] += 1 
	else:
		run_upgrades[upgrade_name] = 1

func process_boss_kill(base_gold_reward: int = 5):
	bosses_defeated_this_run += 1
	var final_gold_reward = base_gold_reward * bosses_defeated_this_run
	self.gold += final_gold_reward


func reset_run_stats():
	save_game()
	run_total_kills = 0
	bosses_defeated_this_run = 0
	run_damage_dealt = 0.0 
	run_kills_by_type.clear()
	achievements_this_run.clear()
	run_upgrades.clear()

func end_run(final_time: float, final_level: int):
	run_damage_dealt = 0.0
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var weapons_manager = player.get_node_or_null("WeaponInventory")
		if weapons_manager:
			for weapon in weapons_manager.get_children():
				if weapon.has_method("get_actual_damage"):
					var dmg = weapon.get("total_damage_dealt")
					if dmg != null:
						run_damage_dealt += dmg
	
	if final_time > highest_survival_time:
		highest_survival_time = final_time
	total_time_played += final_time
	
	if final_level > highest_level_reached:
		highest_level_reached = final_level
		
	lifetime_damage_dealt += run_damage_dealt
	check_achievements()
	
# --- SPEICHERN & LADEN ---
func save_game():
	var config = ConfigFile.new()
	config.set_value("Stats", "total_kills", lifetime_total_kills)
	config.set_value("Stats", "kills_by_type", lifetime_kills_by_type)
	config.set_value("Stats", "total_runs_played", total_runs_played)
	config.set_value("Stats", "lifetime_damage_dealt", lifetime_damage_dealt )
	config.set_value("Stats", "highest_level_reached", highest_level_reached )
	config.set_value("Stats", "run_damage_dealt", run_damage_dealt )
	config.set_value("Stats", "highest_survival_time", highest_survival_time)
	config.set_value("Stats", "total_time_played", total_time_played)
	
	config.set_value("Economy", "gold", gold)
	config.set_value("Economy", "total_gold_earned", total_gold_earned)
	config.set_value("Economy", "unlocked_chars", unlocked_characters)
	config.set_value("Economy", "discovered_weapons", discovered_weapons)
	config.set_value("Economy", "discovered_upgrades", discovered_upgrades)
	config.set_value("Economy", "unlocked_items", unlocked_items)
	config.set_value("Economy", "unlocked_achievements", unlocked_achievements)
	config.save(SAVE_PATH)
	print("Spiel erfolgreich gespeichert!")  # Kleines Feedback für die Konsole


func load_game():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)

	if err == OK:
		lifetime_total_kills = config.get_value("Stats", "total_kills", 0)
		lifetime_kills_by_type = config.get_value("Stats", "kills_by_type", {})
		total_runs_played = config.get_value("Stats", "total_runs_played", 0)
		lifetime_damage_dealt = config.get_value("Stats", "lifetime_damage_dealt", 0)
		highest_level_reached = config.get_value("Stats", "highest_level_reached", 0)
		run_damage_dealt = config.get_value("Stats", "run_damage_dealt", 0)
		highest_survival_time = config.get_value("Stats", "highest_survival_time", 0.0)
		total_time_played = config.get_value("Stats", "total_time_played", 0.0)
		
		gold = config.get_value("Economy", "gold", 0)
		total_gold_earned = config.get_value("Economy", "total_gold_earned", 0)
		unlocked_characters = config.get_value("Economy", "unlocked_chars", ["Soilder"])
		discovered_weapons = config.get_value("Economy", "discovered_weapons", ["knife"])
		discovered_upgrades = config.get_value("Economy", "discovered_upgrades", [])
		unlocked_items = config.get_value("Economy", "unlocked_items", [])
		unlocked_achievements = config.get_value("Economy", "unlocked_achievements", [])
