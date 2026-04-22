class_name UpgradeDatabase
extends Node

static var weapons_db = {
	"knife":
	{
		"name": "Knife",
		"desc": "Throws a fast knife.",
		"rarity": "Common",
		"scene": preload("res://main/weapons/equipable_weapons/range/knife/knife_weapon.tscn"),
		"icon": preload("res://main/weapons/equipable_weapons/range/knife/knife.png")
	},
	"ice_aura":
	{
		"name": "Ice Aura",
		"desc": "Creates a freezing zone.",
		"rarity": "Uncommon",
		"unlock_req" :"runs_1",
		"scene": preload("res://main/weapons/equipable_weapons/aura/ice_aura/ice_aura.tscn"),
		"icon": preload("res://assets/art/icons/weapon_icon/ice_aura.png")
	},
	"chain_lightning":
	{
		"name": "Chain Lightning",
		"desc": "[color=green]New Weapon[/color]\nFires a bouncing bolt of energy.",
		"rarity": "Rare",
		"scene":
		preload("res://main/weapons/equipable_weapons/other/chain_lightning/chain_lightning.tscn"),
		"icon": preload("res://assets/art/icons/weapon_icon/chain_lightning.png")
	},
	"pillar_of_light":
	{
		"name": "Pillar of Light",
		"desc": "[color=green]New Weapon[/color]\nGod strikes the souls.",
		"rarity": "Epic",
		"scene":
		preload("res://main/weapons/equipable_weapons/other/pillar_of_light/pillar_of_light.tscn"),
		"icon": preload("res://assets/art/icons/weapon_icon/pillar_of_light.png")
	},
	"void_orbs":
	{
		"name": "Void Orb",
		"desc": "[color=green]New Weapon[/color]\n ...",
		"rarity": "Legendary",
		"scene": preload("res://main/weapons/equipable_weapons/melee/void_orbs/void_orbs.tscn"),
		"icon": preload("res://assets/art/icons/weapon_icon/void_orbs.png")
	},
	"blood_trail":
	{
		"name": "Blood Trail",
		"desc": "[color=green]New Weapon[/color]\n ...",
		"rarity": "Uncommon",
		"unlock_req": "survive_10_min", #level_100
		"scene": preload("res://main/weapons/equipable_weapons/other/blood_trail/blood_trail.tscn"),
		"icon": preload("res://assets/art/icons/weapon_icon/blood_trail.png")
	},
	"phantom_glaive":
	{
		"name": "Phantom Glaive",
		"desc": "[color=green]New Weapon[/color]\nThrows a spectral blade that returns to you.",
		"rarity": "Rare",
		"scene":
		preload("res://main/weapons/equipable_weapons/range/phantom_glaive/phantom_glaive.tscn"),
		"icon": preload("res://assets/art/icons/weapon_icon/phantom_glaive.png")
	},
	"abyssal_impale":
	{
		"name": "Abyssal Impale",
		"desc": "[color=green]New Weapon[/color]\nSpikes outranging the ground.",
		"rarity": "Epic",
		"scene":
		preload("res://main/weapons/equipable_weapons/other/abyssal_impale/abyssal_impale.tscn"),
		"icon": preload("res://assets/art/icons/weapon_icon/abyssal_impale.png")
	},
}


static var stat_icons: Dictionary = {
	"might": preload("res://assets/art/icons/stats_icon/might_gauntlet.png"),
	"attack_speed_bonus": preload("res://assets/art/icons/stats_icon/attackSpeed_knife.png"),
	"max_health": preload("res://assets/art/icons/stats_icon/hearth.png"),
	"recovery": preload("res://assets/art/icons/stats_icon/recovery_arrow.png"),
	"armor": preload("res://assets/art/icons/stats_icon/armor.png"),
	"speed": preload("res://assets/art/icons/stats_icon/movement_speed_wingboots.png"),
	"area": preload("res://assets/art/icons/stats_icon/area_wave.png"),
	"luck": preload("res://assets/art/icons/stats_icon/luck.png"),
	"magnet_mult": preload("res://assets/art/icons/stats_icon/magnet_soul-xp.png"),
	"growth": preload("res://assets/art/icons/stats_icon/growth.png")
}

static var stat_upgrades = [
	# ==========================================
	# --- MIGHT (OFFENSE) ---
	# ==========================================
	{
		"name": "Sharpen",
		"desc": "[color=green]+10% Damage[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "might", "amount": 0.1}]
	},
	{
		"name": "Whetstone",
		"desc": "[color=green]+12% Damage[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "might", "amount": 0.12}]
	},
	{
		"name": "Soldier's Grit",
		"desc": "[color=green]+8% Damage[/color]\n[color=green]+5 Max Health[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "might", "amount": 0.08}, {"key": "max_health", "amount": 5.0}]
	},
	{
		"name": "Heavy Edge",
		"desc": "[color=green]+15% Damage[/color]\n[color=red]-5% Move Speed[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "might", "amount": 0.15}, {"key": "speed", "amount": -10.0}]
	},
	{
		"name": "Executioner",
		"desc": "[color=green]+20% Damage[/color]\n[color=red]-10% Luck[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "might", "amount": 0.2}, {"key": "luck", "amount": -0.1}]
	},
	{
		"name": "Brute Force",
		"desc": "[color=green]+25% Damage[/color]\n[color=red]-5% Attack Speed[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "might", "amount": 0.25}, {"key": "attack_speed_bonus", "amount": -0.05}]
	},
	{
		"name": "Cursed Edge",
		"desc": "[color=green]+35% Damage[/color]\n[color=red]-10 Armor[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [{"key": "might", "amount": 0.35}, {"key": "armor", "amount": -10.0}]
	},
	{
		"name": "Giant's Might",
		"desc": "[color=green]+35% Damage[/color]\n[color=red]-10% Area[/color]",
		"rarity": "Epic",
		"type": "stat",
		"unlock_req": "kills_100",
		"stats": [{"key": "might", "amount": 0.35}, {"key": "area", "amount": -0.1}]
	},
	{
		"name": "Glass Cannon",
		"desc": "[color=green]+50% Damage[/color]\n[color=red]-20 Max Health[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"unlock_req" :"runs_1",
		"stats": [{"key": "might", "amount": 0.5}, {"key": "max_health", "amount": -20.0}]
	},
	{
		"name": "Berserker Blood",
		"desc": "[color=green]+60% Damage[/color]\n[color=red]-5 Armor[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"unlock_req": "level_100",
		"stats": [{"key": "might", "amount": 0.6}, {"key": "armor", "amount": -5.0}]
	},
	{
		"name": "Pact of the Void",
		"desc": "[color=green]+150% Damage[/color]\n[color=red]-80 Max Health[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"unlock_req": "survive_10_min", 
		"stats": [{"key": "might", "amount": 1.5}, {"key": "max_health", "amount": -80.0}]
	},
	# ==========================================
	# --- ATTACK SPEED (HASTE) ---
	# ==========================================
	{
		"name": "Quick Reflexes",
		"desc": "[color=green]+5% Attack Speed[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "attack_speed_bonus", "amount": 0.05}]
	},
	{
		"name": "Adrenaline",
		"desc": "[color=green]+10% Attack Speed[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "attack_speed_bonus", "amount": 0.1}]
	},
	{
		"name": "Light Weapon",
		"desc": "[color=green]+12% Attack Speed[/color]\n[color=red]-3% Damage[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "attack_speed_bonus", "amount": 0.12}, {"key": "might", "amount": -0.03}]
	},
	{
		"name": "Haste",
		"desc": "[color=green]+15% Attack Speed[/color]\n[color=red]-5% Damage[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "attack_speed_bonus", "amount": 0.15}, {"key": "might", "amount": -0.05}]
	},
	{
		"name": "Flow",
		"desc": "[color=green]+18% Attack Speed[/color]\n[color=red]-5% Pickup Range[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats":
		[{"key": "attack_speed_bonus", "amount": 0.18}, {"key": "magnet_mult", "amount": -0.05}]
	},
	{
		"name": "Frenzy",
		"desc": "[color=green]+20% Attack Speed[/color]\n[color=red]-10% Area[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [{"key": "attack_speed_bonus", "amount": 0.2}, {"key": "area", "amount": -0.1}]
	},
	{
		"name": "Swift Soul",
		"desc": "[color=green]+25% Attack Speed[/color]\n[color=red]-15 Max HP[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats":
		[{"key": "attack_speed_bonus", "amount": 0.25}, {"key": "max_health", "amount": -15.0}]
	},
	{
		"name": "Time Warp",
		"desc": "[color=green]+35% Attack Speed[/color]\n[color=red]-15% Damage[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"stats": [{"key": "attack_speed_bonus", "amount": 0.35}, {"key": "might", "amount": -0.15}]
	},
	{
		"name": "Lightning Strikes",
		"desc": "[color=green]+40% Attack Speed[/color]\n[color=red]-25% Damage[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"stats": [{"key": "attack_speed_bonus", "amount": 0.4}, {"key": "might", "amount": -0.25}]
	},
	# ==========================================
	# --- DEFENSE (HEALTH & ARMOR) ---
	# ==========================================
	{
		"name": "Leather Patch",
		"desc": "[color=green]+1 Armor[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "armor", "amount": 1.0}]
	},
	{
		"name": "Minor Health",
		"desc": "[color=green]+10 Max Health[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "max_health", "amount": 10.0}]
	},
	{
		"name": "Thick Skin",
		"desc": "[color=green]+15 Max Health[/color]\n[color=red]-5 Move Speed[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "max_health", "amount": 15.0}, {"key": "speed", "amount": -5.0}]
	},
	{
		"name": "Iron Plate",
		"desc": "[color=green]+2 Armor[/color]\n[color=red]-5% Attack Speed[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "armor", "amount": 2.0}, {"key": "attack_speed_bonus", "amount": -0.05}]
	},
	{
		"name": "Troll Blood",
		"desc": "[color=green]+0.5 HP/sec Regen[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "recovery", "amount": 0.5}]
	},
	{
		"name": "Stone Skin",
		"desc": "[color=green]+6 Armor[/color]\n[color=red]-20% Area[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "armor", "amount": 6.0}, {"key": "area", "amount": -0.2}]
	},
	{
		"name": "Life Fountain",
		"desc": "[color=green]+40 Max Health[/color]\n[color=red]-10% Damage[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [{"key": "max_health", "amount": 40.0}, {"key": "might", "amount": -0.1}]
	},
	{
		"name": "Heavy Plate",
		"desc": "[color=green]+4 Armor[/color]\n[color=red]-15 Move Speed[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [{"key": "armor", "amount": 4.0}, {"key": "speed", "amount": -15.0}]
	},
	{
		"name": "Juggernaut",
		"desc": "[color=green]+12 Armor[/color]\n[color=red]-40 Move Speed[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"stats": [{"key": "armor", "amount": 12.0}, {"key": "speed", "amount": -40.0}]
	},
	{
		"name": "Undying Will",
		"desc": "[color=green]+100 Max Health[/color]\n[color=red]-30% Damage[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"stats": [{"key": "max_health", "amount": 100.0}, {"key": "might", "amount": -0.3}]
	},
	# ==========================================
	# --- SPEED & AREA ---
	# ==========================================
	{
		"name": "Wider Reach",
		"desc": "[color=green]+10% Area[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "area", "amount": 0.1}]
	},
	{
		"name": "Swift Boots",
		"desc": "[color=green]+25 Move Speed[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "speed", "amount": 25.0}]
	},
	{
		"name": "Scout's Training",
		"desc": "[color=green]+30 Move Speed[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "speed", "amount": 30.0}]
	},
	{
		"name": "Great Swing",
		"desc": "[color=green]+20% Area[/color]\n[color=red]-5% Attack Speed[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "area", "amount": 0.2}, {"key": "attack_speed_bonus", "amount": -0.05}]
	},
	{
		"name": "Titan's Ring",
		"desc": "[color=green]+30% Area[/color]\n[color=red]-20 Move Speed[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "area", "amount": 0.3}, {"key": "speed", "amount": -20.0}]
	},
	{
		"name": "Expanding Force",
		"desc": "[color=green]+40% Area[/color]\n[color=red]-15% Damage[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [{"key": "area", "amount": 0.4}, {"key": "might", "amount": -0.15}]
	},
	{
		"name": "Wind Walker",
		"desc": "[color=green]+60 Move Speed[/color]\n[color=red]-1 Armor[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [{"key": "speed", "amount": 60.0}, {"key": "armor", "amount": -1.0}]
	},
	{
		"name": "Black Hole",
		"desc": "[color=green]+70% Area[/color]\n[color=red]-25% Attack Speed[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"stats": [{"key": "area", "amount": 0.7}, {"key": "attack_speed_bonus", "amount": -0.25}]
	},
	{
		"name": "Phantom Step",
		"desc": "[color=green]+100 Move Speed[/color]\n[color=red]-30 Max HP[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"stats": [{"key": "speed", "amount": 100.0}, {"key": "max_health", "amount": -30.0}]
	},
	# ==========================================
	# --- UTILITY (MAGNET, GROWTH, LUCK) ---
	# ==========================================
	{
		"name": "Small Clover",
		"desc": "[color=green]+12% Luck[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "luck", "amount": 0.12}]
	},
	{
		"name": "Attractor",
		"desc": "[color=green]+30% Pickup Range[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "magnet_mult", "amount": 0.3}]
	},
	{
		"name": "Scholar",
		"desc": "[color=green]+20% XP Gain[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "growth", "amount": 0.2}]
	},
	{
		"name": "Curiosity",
		"desc": "[color=green]+20% Luck[/color]\n[color=green]+10% XP[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "luck", "amount": 0.2}, {"key": "growth", "amount": 0.1}]
	},
	{
		"name": "Golden Horseshoe",
		"desc": "[color=green]+30% Luck[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "luck", "amount": 0.3}]
	},
	{
		"name": "Magnetic Soul",
		"desc": "[color=green]+50% Pickup Range[/color]\n[color=red]-5% Move Speed[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "magnet_mult", "amount": 0.5}, {"key": "speed", "amount": -5.0}]
	},
	{
		"name": "Wisdom",
		"desc": "[color=green]+40% XP Gain[/color]\n[color=red]-10% Damage[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [{"key": "growth", "amount": 0.4}, {"key": "might", "amount": -0.1}]
	},
	{
		"name": "Greed",
		"desc": "[color=green]+60% XP Gain[/color]\n[color=red]-20% Luck[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [{"key": "growth", "amount": 0.6}, {"key": "luck", "amount": -0.2}]
	},
	{
		"name": "Artifact Hunter",
		"desc": "[color=green]+50% Luck[/color]\n[color=red]-10% XP Gain[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"stats": [{"key": "luck", "amount": 0.5}, {"key": "growth", "amount": -0.1}]
	},
	{
		"name": "Hoarder",
		"desc": "[color=green]+100% Pickup Range[/color]\n[color=red]-50% Damage[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"stats": [{"key": "magnet_mult", "amount": 1.0}, {"key": "might", "amount": -0.5}]
	},
	# ==========================================
	# --- THE CURSED COMMONS (Kleine fiese Trade-offs) ---
	# ==========================================
	{
		"name": "Rusty Scalpel",
		"desc": "[color=green]+15% Damage[/color]\n[color=red]-2 Max Health[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "might", "amount": 0.15}, {"key": "max_health", "amount": -2.0}]
	},
	{
		"name": "Torn Muscle",
		"desc": "[color=green]+15% Attack Speed[/color]\n[color=red]-1.0 HP/sec Regen[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats":
		[{"key": "attack_speed_bonus", "amount": 0.15}, {"key": "recovery", "amount": -1.0}]
	},
	{
		"name": "Heavy Shackles",
		"desc": "[color=green]+3 Armor[/color]\n[color=red]-10 Move Speed[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "armor", "amount": 3.0}, {"key": "speed", "amount": -10.0}]
	},
	{
		"name": "Blindfold",
		"desc": "[color=green]+20% Attack Speed[/color]\n[color=red]-15% Area[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "attack_speed_bonus", "amount": 0.20}, {"key": "area", "amount": -0.15}]
	},
	{
		"name": "Chipped Bone",
		"desc": "[color=green]+10% Damage[/color]\n[color=red]-5% Attack Speed[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "might", "amount": 0.1}, {"key": "attack_speed_bonus", "amount": -0.05}]
	},
	{
		"name": "Grave Dirt",
		"desc": "[color=green]+15% XP Gain[/color]\n[color=red]-5% Move Speed[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "growth", "amount": 0.15}, {"key": "speed", "amount": -5.0}]
	},
	{
		"name": "Cracked Lens",
		"desc": "[color=green]+15% Area[/color]\n[color=red]-5% Damage[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "area", "amount": 0.15}, {"key": "might", "amount": -0.05}]
	},
	{
		"name": "Stolen Penny",
		"desc": "[color=green]+20% Luck[/color]\n[color=red]-1 Armor[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "luck", "amount": 0.20}, {"key": "armor", "amount": -1.0}]
	},
	{
		"name": "Tainted Water",
		"desc": "[color=green]+0.5 HP/sec Regen[/color]\n[color=red]-5 Max Health[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "recovery", "amount": 0.5}, {"key": "max_health", "amount": -5.0}]
	},
	{
		"name": "Frail Heart",
		"desc": "[color=green]+20 Max Health[/color]\n[color=red]-0.2 HP/sec Regen[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "max_health", "amount": 20.0}, {"key": "recovery", "amount": -0.2}]
	},
	# ==========================================
	# --- BLOOD MAGIC (HP opfern für Macht - Uncommon/Rare) ---
	# ==========================================
	{
		"name": "Blood Price",
		"desc": "[color=green]+30% Damage[/color]\n[color=red]-10 Max Health[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "might", "amount": 0.3}, {"key": "max_health", "amount": -10.0}]
	},
	{
		"name": "Sinner's Scourge",
		"desc": "[color=green]+25% Attack Speed[/color]\n[color=red]-1.5 HP/sec Regen[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats":
		[{"key": "attack_speed_bonus", "amount": 0.25}, {"key": "recovery", "amount": -1.5}]
	},
	{
		"name": "Flesh Sacrifice",
		"desc": "[color=green]+40% Area[/color]\n[color=red]-15 Max Health[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "area", "amount": 0.4}, {"key": "max_health", "amount": -15.0}]
	},
	{
		"name": "Crimson Pact",
		"desc": "[color=green]+50% Damage[/color]\n[color=red]-25 Max Health[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "might", "amount": 0.5}, {"key": "max_health", "amount": -25.0}]
	},
	{
		"name": "Leech Seed",
		"desc": "[color=green]+2.0 HP/sec Regen[/color]\n[color=red]-20% Damage[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "recovery", "amount": 2.0}, {"key": "might", "amount": -0.2}]
	},
	{
		"name": "Open Wound",
		"desc":
		"[color=green]+30% Attack Speed[/color]\n[color=green]+30 Move Speed[/color]\n[color=red]-3 Armor[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats":
		[
			{"key": "attack_speed_bonus", "amount": 0.3},
			{"key": "speed", "amount": 30.0},
			{"key": "armor", "amount": -3.0}
		]
	},
	{
		"name": "Vampire's Hunger",
		"desc": "[color=green]+3.0 HP/sec Regen[/color]\n[color=red]-30% XP Gain[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [{"key": "recovery", "amount": 3.0}, {"key": "growth", "amount": -0.3}]
	},
	{
		"name": "Blood Boiling",
		"desc":
		"[color=green]+50% Damage[/color]\n[color=green]+50% Attack Speed[/color]\n[color=red]-40 Max Health[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats":
		[
			{"key": "might", "amount": 0.5},
			{"key": "attack_speed_bonus", "amount": 0.5},
			{"key": "max_health", "amount": -40.0}
		]
	},
	# ==========================================
	# --- THE COLOSSUS (Groß, langsam, gepanzert) ---
	# ==========================================
	{
		"name": "Lead Weights",
		"desc": "[color=green]+5 Armor[/color]\n[color=red]-20 Move Speed[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "armor", "amount": 5.0}, {"key": "speed", "amount": -20.0}]
	},
	{
		"name": "Tower Shield",
		"desc": "[color=green]+8 Armor[/color]\n[color=red]-15% Attack Speed[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "armor", "amount": 8.0}, {"key": "attack_speed_bonus", "amount": -0.15}]
	},
	{
		"name": "Overgrown Weapon",
		"desc": "[color=green]+50% Area[/color]\n[color=red]-20% Attack Speed[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "area", "amount": 0.5}, {"key": "attack_speed_bonus", "amount": -0.2}]
	},
	{
		"name": "Stone Golem",
		"desc": "[color=green]+80 Max Health[/color]\n[color=red]-40 Move Speed[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "max_health", "amount": 80.0}, {"key": "speed", "amount": -40.0}]
	},
	{
		"name": "Immovable Object",
		"desc": "[color=green]+15 Armor[/color]\n[color=red]-80 Move Speed[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [{"key": "armor", "amount": 15.0}, {"key": "speed", "amount": -80.0}]
	},
	{
		"name": "Mountain Breaker",
		"desc": "[color=green]+80% Damage[/color]\n[color=red]-40% Attack Speed[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [{"key": "might", "amount": 0.8}, {"key": "attack_speed_bonus", "amount": -0.4}]
	},
	{
		"name": "World Atlas",
		"desc": "[color=green]+100% Area[/color]\n[color=red]-50 Move Speed[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [{"key": "area", "amount": 1.0}, {"key": "speed", "amount": -50.0}]
	},
	{
		"name": "Iron Maiden",
		"desc": "[color=green]+20 Armor[/color]\n[color=red]-5.0 HP/sec Regen[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"stats": [{"key": "armor", "amount": 20.0}, {"key": "recovery", "amount": -5.0}]
	},
	# ==========================================
	# --- THE MADMAN (Viel Angriff, keine Verteidigung) ---
	# ==========================================
	{
		"name": "Reckless Swing",
		"desc": "[color=green]+30% Damage[/color]\n[color=red]-2 Armor[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "might", "amount": 0.3}, {"key": "armor", "amount": -2.0}]
	},
	{
		"name": "Tunnel Vision",
		"desc": "[color=green]+40% Damage[/color]\n[color=red]-30% Area[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "might", "amount": 0.4}, {"key": "area", "amount": -0.3}]
	},
	{
		"name": "Machine Gunner",
		"desc": "[color=green]+60% Attack Speed[/color]\n[color=red]-30% Damage[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [{"key": "attack_speed_bonus", "amount": 0.6}, {"key": "might", "amount": -0.3}]
	},
	{
		"name": "Naked Blade",
		"desc": "[color=green]+70% Damage[/color]\n[color=red]-8 Armor[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [{"key": "might", "amount": 0.7}, {"key": "armor", "amount": -8.0}]
	},
	{
		"name": "Kamikaze",
		"desc":
		"[color=green]+100% Damage[/color]\n[color=green]+100 Move Speed[/color]\n[color=red]-10 Armor[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"stats":
		[
			{"key": "might", "amount": 1.0},
			{"key": "speed", "amount": 100.0},
			{"key": "armor", "amount": -10.0}
		]
	},
	{
		"name": "Death's Dance",
		"desc": "[color=green]+80% Attack Speed[/color]\n[color=red]-80 Max Health[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"stats":
		[{"key": "attack_speed_bonus", "amount": 0.8}, {"key": "max_health", "amount": -80.0}]
	},
	# ==========================================
	# --- SCHOLAR's FOLLY (XP/Luck gegen Stats) ---
	# ==========================================
	{
		"name": "Heavy Tome",
		"desc": "[color=green]+30% XP Gain[/color]\n[color=red]-15 Move Speed[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "growth", "amount": 0.3}, {"key": "speed", "amount": -15.0}]
	},
	{
		"name": "Distracting Gem",
		"desc": "[color=green]+40% Luck[/color]\n[color=red]-10% Attack Speed[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "luck", "amount": 0.4}, {"key": "attack_speed_bonus", "amount": -0.1}]
	},
	{
		"name": "Cursed Gold",
		"desc": "[color=green]+80% Luck[/color]\n[color=red]-20% Damage[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "luck", "amount": 0.8}, {"key": "might", "amount": -0.2}]
	},
	{
		"name": "Forbidden Knowledge",
		"desc": "[color=green]+100% XP Gain[/color]\n[color=red]-50 Max Health[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [{"key": "growth", "amount": 1.0}, {"key": "max_health", "amount": -50.0}]
	},
	{
		"name": "Lazy Looter",
		"desc": "[color=green]+200% Pickup Range[/color]\n[color=red]-30 Move Speed[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [{"key": "magnet_mult", "amount": 2.0}, {"key": "speed", "amount": -30.0}]
	},
	{
		"name": "Midas Touch",
		"desc":
		"[color=green]+150% Luck[/color]\n[color=red]-5 Armor[/color]\n[color=red]-20% Damage[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"stats":
		[
			{"key": "luck", "amount": 1.5},
			{"key": "armor", "amount": -5.0},
			{"key": "might", "amount": -0.2}
		]
	},
	# ==========================================
	# --- ABYSSAL PACTS (Legendary Game-Changers) ---
	# ==========================================
	{
		"name": "Pact of the Void",
		"desc": "[color=green]+150% Damage[/color]\n[color=red]-80 Max Health[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"stats": [{"key": "might", "amount": 1.5}, {"key": "max_health", "amount": -80.0}]
	},
	{
		"name": "Time Stop",
		"desc": "[color=green]+150% Attack Speed[/color]\n[color=red]-70% Area[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"stats": [{"key": "attack_speed_bonus", "amount": 1.5}, {"key": "area", "amount": -0.7}]
	},
	{
		"name": "Supermassive",
		"desc": "[color=green]+150% Area[/color]\n[color=red]-80 Move Speed[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"stats": [{"key": "area", "amount": 1.5}, {"key": "speed", "amount": -80.0}]
	},
	{
		"name": "Immortality Paradox",
		"desc": "[color=green]+10.0 HP/sec Regen[/color]\n[color=red]-90% Damage[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"stats": [{"key": "recovery", "amount": 10.0}, {"key": "might", "amount": -0.9}]
	},
	{
		"name": "God of War",
		"desc":
		"[color=green]+100% Damage[/color]\n[color=green]+100% Attack Speed[/color]\n[color=red]-200 Max Health[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"stats":
		[
			{"key": "might", "amount": 1.0},
			{"key": "attack_speed_bonus", "amount": 1.0},
			{"key": "max_health", "amount": -200.0}
		]
	},
	# ==========================================
	# --- GENERAL FILLERS (Normale Upgrades zur Verdünnung) ---
	# ==========================================
	{
		"name": "Iron Horseshoe",
		"desc": "[color=green]+15% Luck[/color]\n[color=green]+1 Armor[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "luck", "amount": 0.15}, {"key": "armor", "amount": 1.0}]
	},
	{
		"name": "Silver Ring",
		"desc": "[color=green]+15% Area[/color]\n[color=green]+15% Pickup Range[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "area", "amount": 0.15}, {"key": "magnet_mult", "amount": 0.15}]
	},
	{
		"name": "Vitality Gem",
		"desc": "[color=green]+25 Max Health[/color]\n[color=green]+0.5 HP/sec Regen[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "max_health", "amount": 25.0}, {"key": "recovery", "amount": 0.5}]
	},
	{
		"name": "Assassin's Mark",
		"desc": "[color=green]+25% Damage[/color]\n[color=green]+15 Move Speed[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "might", "amount": 0.25}, {"key": "speed", "amount": 15.0}]
	},
	{
		"name": "Aura of Decay",
		"desc": "[color=green]+30% Area[/color]\n[color=green]+20% Damage[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [{"key": "area", "amount": 0.3}, {"key": "might", "amount": 0.2}]
	},
]
