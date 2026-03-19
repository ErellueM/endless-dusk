extends Node

var selected_character_scene: PackedScene = null
const SAVE_PATH = "user://savegame.cfg"

# --- RUN STATS ---
var run_total_kills: int = 0
var run_kills_by_type: Dictionary = {}

# --- LIFETIME STATS ---
var lifetime_total_kills: int = 0
var lifetime_kills_by_type: Dictionary = {}

func _ready():
	load_game() # Lädt die Lifetime-Stats direkt beim Spielstart

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
	
	# Optional: Nach jedem Kill speichern (oder am Ende des Runs)
	save_game()

func reset_run_stats():
	run_total_kills = 0
	run_kills_by_type.clear()

# --- SPEICHERN & LADEN ---

func save_game():
	var config = ConfigFile.new()
	config.set_value("Stats", "total_kills", lifetime_total_kills)
	config.set_value("Stats", "kills_by_type", lifetime_kills_by_type)
	config.save(SAVE_PATH)

func load_game():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	
	if err == OK:
		lifetime_total_kills = config.get_value("Stats", "total_kills", 0)
		lifetime_kills_by_type = config.get_value("Stats", "kills_by_type", {})
