extends Node

var selected_character_scene: PackedScene = load(
	"res://main/entities/Characters/PlayableCharacter_01.tscn"
)
const SAVE_PATH = "user://savegame.cfg"

var unlocked_characters: Array = ["Soilder"]

var total_runs_played: int = 0

var highest_survival_time: float = 0.0

# --- RUN STATS ---
var run_total_kills: int = 0
var run_kills_by_type: Dictionary = {}

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

# We ONLY store the scene path now!
var monsters_db = {
	"Green Slime": {
		"scene": preload("res://main/entities/enemies/dump_swarm_enemy/swarm_enemies/green_slime.tscn"),
		"category": "Swarm"
	},
	"Red Slime": {
		"scene": preload("res://main/entities/enemies/dump_swarm_enemy/swarm_enemies/red_slime.tscn"),
		"category": "Swarm"
	},
	"Tank Slime": {
		"scene": preload("res://main/entities/enemies/dump_swarm_enemy/swarm_enemies/tank_slime.tscn"),
		"category": "Swarm"
	},
	"Mushroom Brute": {
		"scene": preload("res://main/entities/enemies/simple_enemy/mushroom_brute/mushroom_brute.tscn"),
		"category": "Normal"
	},
	"Wheel": {
		"scene": preload("res://main/entities/enemies/simple_enemy/wheel/wheel.tscn"),
		"category": "Normal"
	},
	"Tollkeeper": {
		"scene": preload("res://main/entities/enemies/simple_enemy/tollkeeper/tollkeeper.tscn"),
		"category": "Normal"
	},
	"Plague Doctor": {
		"scene": preload("res://main/entities/enemies/simple_ranged_enemy/plagueDoctor/plague_doctor.tscn"),
		"category": "Normal"
	},
	"Slime King": {
		"scene": preload("res://main/entities/enemies/miniboss/slime_king/slime_king.tscn"),
		"category": "Miniboss"
	}
}


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


func reset_run_stats():
	save_game()
	run_total_kills = 0
	run_kills_by_type.clear()


# --- SPEICHERN & LADEN ---


func save_game():
	var config = ConfigFile.new()
	config.set_value("Stats", "total_kills", lifetime_total_kills)
	config.set_value("Stats", "kills_by_type", lifetime_kills_by_type)
	config.set_value("Stats", "total_runs_played", total_runs_played)
	config.set_value("Stats", "highest_survival_time", highest_survival_time)
	
	config.set_value("Economy", "gold", gold)
	config.set_value("Economy", "total_gold_earned", total_gold_earned)
	config.set_value("Economy", "unlocked_chars", unlocked_characters)
	config.save(SAVE_PATH)
	print("Spiel erfolgreich gespeichert!")  # Kleines Feedback für die Konsole


func load_game():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)

	if err == OK:
		lifetime_total_kills = config.get_value("Stats", "total_kills", 0)
		lifetime_kills_by_type = config.get_value("Stats", "kills_by_type", {})
		total_runs_played = config.get_value("Stats", "total_runs_played", 0)
		highest_survival_time = config.get_value("Stats", "highest_survival_time", 0.0)
		
		gold = config.get_value("Economy", "gold", 0)
		total_gold_earned = config.get_value("Economy", "total_gold_earned", 0)
		unlocked_characters = config.get_value("Economy", "unlocked_chars", ["Soilder"])
