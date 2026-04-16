extends Node

var selected_character_scene: PackedScene = load(
	"res://main/entities/Characters/PlayableCharacter_01.tscn"
)
const SAVE_PATH = "user://savegame.cfg"

var unlocked_characters: Array = ["Soilder"]

var total_runs_played: int = 0
var total_gold_earned: int = 0
var highest_survival_time: float = 0.0

# --- RUN STATS ---
var run_total_kills: int = 0
var run_kills_by_type: Dictionary = {}

# --- LIFETIME STATS ---
var lifetime_total_kills: int = 0
var lifetime_kills_by_type: Dictionary = {}

signal gold_changed(new_amount)

var gold: int = 0:
	set(value):
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

	# DIE HANDBREMSE WURDE GELÖST!
	# Hier wird nicht mehr auf die Festplatte geschrieben!


func reset_run_stats():
	# Wir speichern die Lifetime-Stats EINMALIG am Ende des Runs,
	# kurz bevor die aktuellen Run-Stats gelöscht werden!
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
