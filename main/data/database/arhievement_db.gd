class_name AchievementDatabase
extends Node

# Hier definieren wir zentral, welches Icon für welchen Typ Achievement geladen wird.
static var type_icons = {
	"time": preload("res://assets/art/icons/achievements_icon/time.png"),
	"kills": preload("res://assets/art/icons/achievements_icon/skull2.png"),
	"damage": preload("res://assets/art/icons/achievements_icon/damage.png"),
	"level": preload("res://assets/art/icons/achievements_icon/level.png"),
	"gold": preload("res://assets/art/destructables/barrel/item_drops/coin.png"),
	"runs": preload("res://assets/art/icons/achievements_icon/run.png")
}

static var achievements = {
# --- SURVIVAL TIME ---
	"survive_5_min":   {"name": "Novice Survivor", "type": "time", "target": 300.0, "desc": "Survive for 5 minutes"},
	"survive_10_min":  {"name": "Skilled Survivor", "type": "time", "target": 600.0, "desc": "Survive for 10 minutes"},
	"survive_20_min":  {"name": "Veteran Survivor", "type": "time", "target": 1200.0, "desc": "Survive for 20 minutes"},
	"survive_30_min":  {"name": "Elite Survivor", "type": "time", "target": 1800.0, "desc": "Survive for 30 minutes"},
	"survive_60_min":  {"name": "Timeless Legend", "type": "time", "target": 3600.0, "desc": "Survive for 60 minutes"},

	# --- KILLS (LIFETIME) ---
	"kills_100":       {"name": "First Blood", "type": "kills", "target": 100, "desc": "Kill 100 monsters"},
	"kills_1k":        {"name": "Monster Hunter", "type": "kills", "target": 1000, "desc": "Kill 1,000 monsters"},
	"kills_10k":       {"name": "Slayer", "type": "kills", "target": 10000, "desc": "Kill 10,000 monsters"},
	"kills_100k":      {"name": "Death Incarnate", "type": "kills", "target": 100000, "desc": "Kill 100,000 monsters"},
	"kills_1M":        {"name": "Genocidal", "type": "kills", "target": 1000000, "desc": "Kill 1,000,000 monsters"},
	"kills_1B":        {"name": "God of Destruction", "type": "kills", "target": 1000000000, "desc": "Kill 1,000,000,000 monsters"},

	# --- DAMAGE (LIFETIME) ---
	"dmg_10k":         {"name": "Hitter", "type": "damage", "target": 10000.0, "desc": "Deal 10,000 total damage"},
	"dmg_100k":        {"name": "Destroyer", "type": "damage", "target": 100000.0, "desc": "Deal 100,000 total damage"},
	"dmg_1M":          {"name": "Devastator", "type": "damage", "target": 1000000.0, "desc": "Deal 1,000,000 total damage"},
	"dmg_10M":         {"name": "Cataclysm", "type": "damage", "target": 10000000.0, "desc": "Deal 10,000,000 total damage"},
	"dmg_100M":        {"name": "Star Crusher", "type": "damage", "target": 100000000.0, "desc": "Deal 100,000,000 total damage"},

	# --- LEVEL ---
	"level_10":        {"name": "Apprentice", "type": "level", "target": 10, "desc": "Reach Level 10"},
	"level_25":        {"name": "Adventurer", "type": "level", "target": 25, "desc": "Reach Level 25"},
	"level_50":        {"name": "Master", "type": "level", "target": 50, "desc": "Reach Level 50"},
	"level_100":       {"name": "Transcendent", "type": "level", "target": 100, "desc": "Reach Level 100"},

	# --- GOLD EARNED ---
	"gold_1k":         {"name": "Pocket Money", "type": "gold", "target": 1000, "desc": "Earn 1,000 total gold"},
	"gold_10k":        {"name": "Wealthy", "type": "gold", "target": 10000, "desc": "Earn 10,000 total gold"},
	"gold_100k":       {"name": "Treasurer", "type": "gold", "target": 100000, "desc": "Earn 100,000 total gold"},
	"gold_1M":         {"name": "Midas Touch", "type": "gold", "target": 1000000, "desc": "Earn 1,000,000 total gold"},

	# --- TOTAL RUNS ---
	"runs_1":          {"name": "First Step", "type": "runs", "target": 1, "desc": "Start your first run"},
	"runs_10":         {"name": "Persistent", "type": "runs", "target": 10, "desc": "Complete 10 runs"},
	"runs_50":         {"name": "Addicted", "type": "runs", "target": 50, "desc": "Complete 50 runs"},
	"runs_100":        {"name": "Veteran", "type": "runs", "target": 100, "desc": "Complete 100 runs"},
	"runs_500":        {"name": "Legendary Hero", "type": "runs", "target": 500, "desc": "Complete 500 runs"}
}
