# upgrade_database.gd
class_name UpgradeDatabase
extends Node

# Tipp: In Godot als 'Autoload' registrieren oder einfach static nutzen
static var stat_upgrades = [
	# --- MIGHT (OFFENSE) ---
	{"name": "Sharpen", "desc": "[color=green]+10% Damage[/color]", "rarity": "Common", "type": "stat", "stats": [{"key": "might", "amount": 0.1}]},
	{"name": "Heavy Edge", "desc": "[color=green]+15% Damage[/color]\n[color=red]-5% Move Speed[/color]", "rarity": "Common", "type": "stat", "stats": [{"key": "might", "amount": 0.15}, {"key": "speed", "amount": -10.0}]},
	{"name": "Brute Force", "desc": "[color=green]+25% Damage[/color]\n[color=red]-5% Attack Speed[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "might", "amount": 0.25}, {"key": "attack_speed_bonus", "amount": -0.05}]},
	{"name": "Giant's Might", "desc": "[color=green]+35% Damage[/color]\n[color=red]-10% Area[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "might", "amount": 0.35}, {"key": "area", "amount": -0.1}]},
	{"name": "Glass Cannon", "desc": "[color=green]+50% Damage[/color]\n[color=red]-20 Max Health[/color]", "rarity": "Legendary", "type": "stat", "stats": [{"key": "might", "amount": 0.5}, {"key": "max_health", "amount": -20.0}]},
	{"name": "Berserker Blood", "desc": "[color=green]+60% Damage[/color]\n[color=red]-5 Armor[/color]", "rarity": "Legendary", "type": "stat", "stats": [{"key": "might", "amount": 0.6}, {"key": "armor", "amount": -5.0}]},
	{"name": "Soldier's Grit", "desc": "[color=green]+8% Damage[/color]\n[color=green]+5 Max Health[/color]", "rarity": "Common", "type": "stat", "stats": [{"key": "might", "amount": 0.08}, {"key": "max_health", "amount": 5.0}]},
	{"name": "Whetstone", "desc": "[color=green]+12% Damage[/color]", "rarity": "Common", "type": "stat", "stats": [{"key": "might", "amount": 0.12}]},
	{"name": "Executioner", "desc": "[color=green]+20% Damage[/color]\n[color=red]-10% Luck[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "might", "amount": 0.2}, {"key": "luck", "amount": -0.1}]},
	{"name": "Abyssal Power", "desc": "[color=green]+40% Damage[/color]\n[color=red]-1.0 Recovery[/color]", "rarity": "Legendary", "type": "stat", "stats": [{"key": "might", "amount": 0.4}, {"key": "recovery", "amount": -1.0}]},

	# --- ATTACK SPEED (HASTE) ---
	{"name": "Quick Reflexes", "desc": "[color=green]+5% Attack Speed[/color]", "rarity": "Common", "type": "stat", "stats": [{"key": "attack_speed_bonus", "amount": 0.05}]},
	{"name": "Light Weapon", "desc": "[color=green]+8% Attack Speed[/color]\n[color=red]-3% Damage[/color]", "rarity": "Common", "type": "stat", "stats": [{"key": "attack_speed_bonus", "amount": 0.08}, {"key": "might", "amount": -0.03}]},
	{"name": "Haste", "desc": "[color=green]+15% Attack Speed[/color]\n[color=red]-5% Damage[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "attack_speed_bonus", "amount": 0.15}, {"key": "might", "amount": -0.05}]},
	{"name": "Frenzy", "desc": "[color=green]+20% Attack Speed[/color]\n[color=red]-10% Area[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "attack_speed_bonus", "amount": 0.2}, {"key": "area", "amount": -0.1}]},
	{"name": "Time Warp", "desc": "[color=green]+35% Attack Speed[/color]\n[color=red]-15% Damage[/color]", "rarity": "Legendary", "type": "stat", "stats": [{"key": "attack_speed_bonus", "amount": 0.35}, {"key": "might", "amount": -0.15}]},
	{"name": "Celerity", "desc": "[color=green]+10% Attack Speed[/color]\n[color=green]+10 Move Speed[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "attack_speed_bonus", "amount": 0.1}, {"key": "speed", "amount": 10.0}]},
	{"name": "Adrenaline", "desc": "[color=green]+12% Attack Speed[/color]", "rarity": "Common", "type": "stat", "stats": [{"key": "attack_speed_bonus", "amount": 0.12}]},
	{"name": "Flow", "desc": "[color=green]+18% Attack Speed[/color]\n[color=red]-5% Pickup Range[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "attack_speed_bonus", "amount": 0.18}, {"key": "magnet_mult", "amount": -0.05}]},
	{"name": "Lightning Strikes", "desc": "[color=green]+40% Attack Speed[/color]\n[color=red]-25% Damage[/color]", "rarity": "Legendary", "type": "stat", "stats": [{"key": "attack_speed_bonus", "amount": 0.4}, {"key": "might", "amount": -0.25}]},
	{"name": "Swift Soul", "desc": "[color=green]+25% Attack Speed[/color]\n[color=red]-15 Max HP[/color]", "rarity": "Legendary", "type": "stat", "stats": [{"key": "attack_speed_bonus", "amount": 0.25}, {"key": "max_health", "amount": -15.0}]},

	# --- DEFENSE (HEALTH & ARMOR) ---
	{"name": "Minor Health", "desc": "[color=green]+10 Max Health[/color]", "rarity": "Common", "type": "stat", "stats": [{"key": "max_health", "amount": 10.0}]},
	{"name": "Thick Skin", "desc": "[color=green]+15 Max Health[/color]\n[color=red]-5 Move Speed[/color]", "rarity": "Common", "type": "stat", "stats": [{"key": "max_health", "amount": 15.0}, {"key": "speed", "amount": -5.0}]},
	{"name": "Leather Patch", "desc": "[color=green]+1 Armor[/color]", "rarity": "Common", "type": "stat", "stats": [{"key": "armor", "amount": 1.0}]},
	{"name": "Iron Plate", "desc": "[color=green]+2 Armor[/color]\n[color=red]-5% Attack Speed[/color]", "rarity": "Common", "type": "stat", "stats": [{"key": "armor", "amount": 2.0}, {"key": "attack_speed_bonus", "amount": -0.05}]},
	{"name": "Troll Blood", "desc": "[color=green]+0.5 HP/sec Regen[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "recovery", "amount": 0.5}]},
	{"name": "Heavy Plate", "desc": "[color=green]+4 Armor[/color]\n[color=red]-15 Move Speed[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "armor", "amount": 4.0}, {"key": "speed", "amount": -15.0}]},
	{"name": "Life Fountain", "desc": "[color=green]+40 Max Health[/color]\n[color=red]-10% Damage[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "max_health", "amount": 40.0}, {"key": "might", "amount": -0.1}]},
	{"name": "Vampire Vial", "desc": "[color=green]+2.0 HP/sec Regen[/color]\n[color=red]-25 Max Health[/color]", "rarity": "Legendary", "type": "stat", "stats": [{"key": "recovery", "amount": 2.0}, {"key": "max_health", "amount": -25.0}]},
	{"name": "Juggernaut", "desc": "[color=green]+12 Armor[/color]\n[color=red]-40 Move Speed[/color]", "rarity": "Legendary", "type": "stat", "stats": [{"key": "armor", "amount": 12.0}, {"key": "speed", "amount": -40.0}]},
	{"name": "Undying Will", "desc": "[color=green]+100 Max Health[/color]\n[color=red]-30% Damage[/color]", "rarity": "Legendary", "type": "stat", "stats": [{"key": "max_health", "amount": 100.0}, {"key": "might", "amount": -0.3}]},
	{"name": "Stone Skin", "desc": "[color=green]+6 Armor[/color]\n[color=red]-20% Area[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "armor", "amount": 6.0}, {"key": "area", "amount": -0.2}]},
	{"name": "Regenerate", "desc": "[color=green]+0.8 HP/sec Regen[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "recovery", "amount": 0.8}]},
	{"name": "Paladin's Aura", "desc": "[color=green]+3 Armor[/color]\n[color=green]+10 Max HP[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "armor", "amount": 3.0}, {"key": "max_health", "amount": 10.0}]},
	{"name": "Barkshield", "desc": "[color=green]+2 Armor[/color]\n[color=green]+0.2 Regen[/color]", "rarity": "Common", "type": "stat", "stats": [{"key": "armor", "amount": 2.0}, {"key": "recovery", "amount": 0.2}]},
	{"name": "Blood Siphon", "desc": "[color=green]+1.5 HP/sec Regen[/color]\n[color=red]-10% XP Gain[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "recovery", "amount": 1.5}, {"key": "growth", "amount": -0.1}]},

	# --- SPEED & AREA ---
	{"name": "Swift Boots", "desc": "[color=green]+25 Move Speed[/color]", "rarity": "Common", "type": "stat", "stats": [{"key": "speed", "amount": 25.0}]},
	{"name": "Wind Walker", "desc": "[color=green]+60 Move Speed[/color]\n[color=red]-1 Armor[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "speed", "amount": 60.0}, {"key": "armor", "amount": -1.0}]},
	{"name": "Wider Reach", "desc": "[color=green]+10% Area[/color]", "rarity": "Common", "type": "stat", "stats": [{"key": "area", "amount": 0.1}]},
	{"name": "Great Swing", "desc": "[color=green]+20% Area[/color]\n[color=red]-5% Attack Speed[/color]", "rarity": "Common", "type": "stat", "stats": [{"key": "area", "amount": 0.2}, {"key": "attack_speed_bonus", "amount": -0.05}]},
	{"name": "Expanding Force", "desc": "[color=green]+40% Area[/color]\n[color=red]-15% Damage[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "area", "amount": 0.4}, {"key": "might", "amount": -0.15}]},
	{"name": "Black Hole", "desc": "[color=green]+70% Area[/color]\n[color=red]-25% Attack Speed[/color]", "rarity": "Legendary", "type": "stat", "stats": [{"key": "area", "amount": 0.7}, {"key": "attack_speed_bonus", "amount": -0.25}]},
	{"name": "Feather Weight", "desc": "[color=green]+40 Move Speed[/color]\n[color=green]+10% Attack Speed[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "speed", "amount": 40.0}, {"key": "attack_speed_bonus", "amount": 0.1}]},
	{"name": "Scout's Training", "desc": "[color=green]+30 Move Speed[/color]", "rarity": "Common", "type": "stat", "stats": [{"key": "speed", "amount": 30.0}]},
	{"name": "Titan's Ring", "desc": "[color=green]+30% Area[/color]\n[color=red]-20 Move Speed[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "area", "amount": 0.3}, {"key": "speed", "amount": -20.0}]},
	{"name": "Phantom Step", "desc": "[color=green]+100 Move Speed[/color]\n[color=red]-30 Max HP[/color]", "rarity": "Legendary", "type": "stat", "stats": [{"key": "speed", "amount": 100.0}, {"key": "max_health", "amount": -30.0}]},

	# --- UTILITY (MAGNET, GROWTH, LUCK) ---
	{"name": "Attractor", "desc": "[color=green]+30% Pickup Range[/color]", "rarity": "Common", "type": "stat", "stats": [{"key": "magnet_mult", "amount": 0.3}]},
	{"name": "Magnetic Soul", "desc": "[color=green]+50% Pickup Range[/color]\n[color=red]-5% Move Speed[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "magnet_mult", "amount": 0.5}, {"key": "speed", "amount": -5.0}]},
	{"name": "Scholar", "desc": "[color=green]+20% XP Gain[/color]", "rarity": "Common", "type": "stat", "stats": [{"key": "growth", "amount": 0.2}]},
	{"name": "Wisdom", "desc": "[color=green]+40% XP Gain[/color]\n[color=red]-10% Damage[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "growth", "amount": 0.4}, {"key": "might", "amount": -0.1}]},
	{"name": "Greed", "desc": "[color=green]+60% XP Gain[/color]\n[color=red]-20% Luck[/color]", "rarity": "Legendary", "type": "stat", "stats": [{"key": "growth", "amount": 0.6}, {"key": "luck", "amount": -0.2}]},
	{"name": "Small Clover", "desc": "[color=green]+12% Luck[/color]", "rarity": "Common", "type": "stat", "stats": [{"key": "luck", "amount": 0.12}]},
	{"name": "Golden Horseshoe", "desc": "[color=green]+30% Luck[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "luck", "amount": 0.3}]},
	{"name": "Artifact Hunter", "desc": "[color=green]+50% Luck[/color]\n[color=red]-10% XP Gain[/color]", "rarity": "Legendary", "type": "stat", "stats": [{"key": "luck", "amount": 0.5}, {"key": "growth", "amount": -0.1}]},
	{"name": "Hoarder", "desc": "[color=green]+100% Pickup Range[/color]\n[color=red]-50% Damage[/color]", "rarity": "Legendary", "type": "stat", "stats": [{"key": "magnet_mult", "amount": 1.0}, {"key": "might", "amount": -0.5}]},
	{"name": "Curiosity", "desc": "[color=green]+20% Luck[/color]\n[color=green]+10% XP[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "luck", "amount": 0.2}, {"key": "growth", "amount": 0.1}]},

	# --- MIXED & CURSED (RISK REWARD) ---
	{"name": "Blood Rite", "desc": "[color=green]+40% Damage[/color]\n[color=red]-1.5 HP/sec Regen[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "might", "amount": 0.4}, {"key": "recovery", "amount": -1.5}]},
	{"name": "Soul Link", "desc": "[color=green]+15% Damage[/color]\n[color=green]+15% XP Gain[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "might", "amount": 0.15}, {"key": "growth", "amount": 0.15}]},
	{"name": "Iron Mind", "desc": "[color=green]+5 Armor[/color]\n[color=green]+15% Luck[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "armor", "amount": 5.0}, {"key": "luck", "amount": 0.15}]},
	{"name": "Hermit's Path", "desc": "[color=green]+3.0 HP/sec Regen[/color]\n[color=red]-50% Area[/color]", "rarity": "Legendary", "type": "stat", "stats": [{"key": "recovery", "amount": 3.0}, {"key": "area", "amount": -0.5}]},
	{"name": "Broken Seal", "desc": "[color=green]+50% Attack Speed[/color]\n[color=red]-5 Armor[/color]", "rarity": "Legendary", "type": "stat", "stats": [{"key": "attack_speed_bonus", "amount": 0.5}, {"key": "armor", "amount": -5.0}]},
	{"name": "Chaos Spark", "desc": "[color=green]+20% All Stats[/color]\n[color=red]-40 Max HP[/color]", "rarity": "Legendary", "type": "stat", "stats": [{"key": "might", "amount": 0.2}, {"key": "attack_speed_bonus", "amount": 0.2}, {"key": "area", "amount": 0.2}, {"key": "max_health", "amount": -40.0}]},
	{"name": "Frail Strength", "desc": "[color=green]+45% Damage[/color]\n[color=red]-20% Luck[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "might", "amount": 0.45}, {"key": "luck", "amount": -0.2}]},
	{"name": "Heavy Heart", "desc": "[color=green]+50 Max HP[/color]\n[color=red]-30 Move Speed[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "max_health", "amount": 50.0}, {"key": "speed", "amount": -30.0}]},
	{"name": "Light Mind", "desc": "[color=green]+15% Attack Speed[/color]\n[color=green]+15% Area[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "attack_speed_bonus", "amount": 0.15}, {"key": "area", "amount": 0.15}]},
	{"name": "Lucky Coin", "desc": "[color=green]+20% Luck[/color]\n[color=green]+10 Move Speed[/color]", "rarity": "Common", "type": "stat", "stats": [{"key": "luck", "amount": 0.2}, {"key": "speed", "amount": 10.0}]},
	
	# ... (hier kannst du die Liste auf 100 auffüllen, indem du Werte leicht variierst) ...
	{"name": "Simple Ring", "desc": "[color=green]+5% Damage[/color]\n[color=green]+5% Attack Speed[/color]", "rarity": "Common", "stats": [{"key": "might", "amount": 0.05}, {"key": "attack_speed_bonus", "amount": 0.05}]},
	{"name": "Duelist", "desc": "[color=green]+15% Damage[/color]\n[color=red]-5% Area[/color]", "rarity": "Common", "stats": [{"key": "might", "amount": 0.15}, {"key": "area", "amount": -0.05}]},
	{"name": "Sturdy", "desc": "[color=green]+1 Armor[/color]\n[color=green]+5 Max HP[/color]", "rarity": "Common", "stats": [{"key": "armor", "amount": 1.0}, {"key": "max_health", "amount": 5.0}]},
	{"name": "Blink", "desc": "[color=green]+15 Move Speed[/color]\n[color=green]+5% Attack Speed[/color]", "rarity": "Common", "stats": [{"key": "speed", "amount": 15.0}, {"key": "attack_speed_bonus", "amount": 0.05}]},
	{"name": "Greedy Eye", "desc": "[color=green]+20% XP Gain[/color]\n[color=red]-5% Damage[/color]", "rarity": "Common", "stats": [{"key": "growth", "amount": 0.2}, {"key": "might", "amount": -0.05}]},
	{"name": "Steel Skin", "desc": "[color=green]+2 Armor[/color]\n[color=red]-5% Luck[/color]", "rarity": "Common", "stats": [{"key": "armor", "amount": 2.0}, {"key": "luck", "amount": -0.05}]},
	{"name": "Sharp Eye", "desc": "[color=green]+10% Area[/color]\n[color=green]+5% Luck[/color]", "rarity": "Common", "stats": [{"key": "area", "amount": 0.1}, {"key": "luck", "amount": 0.05}]},
	{"name": "Restoration", "desc": "[color=green]+0.3 HP/sec[/color]\n[color=green]+5 Max HP[/color]", "rarity": "Common", "stats": [{"key": "recovery", "amount": 0.3}, {"key": "max_health", "amount": 5.0}]},
	{"name": "Cursed Edge", "desc": "[color=green]+35% Damage[/color]\n[color=red]-10 Armor[/color]", "rarity": "Legendary", "stats": [{"key": "might", "amount": 0.35}, {"key": "armor", "amount": -10.0}]},
	{"name": "Grave Digger", "desc": "[color=green]+30% Luck[/color]\n[color=red]-20% XP Gain[/color]", "rarity": "Rare", "stats": [{"key": "luck", "amount": 0.3}, {"key": "growth", "amount": -0.2}]},
	{"name": "Wind In A Bottle", "desc": "[color=green]+40 Move Speed[/color]\n[color=red]-10% Area[/color]", "rarity": "Rare", "stats": [{"key": "speed", "amount": 40.0}, {"key": "area", "amount": -0.1}]},
	{"name": "Meditation", "desc": "[color=green]+1.0 HP/sec[/color]\n[color=red]-10% Damage[/color]", "rarity": "Rare", "stats": [{"key": "recovery", "amount": 1.0}, {"key": "might", "amount": -0.1}]},
	{"name": "Obsidian Armor", "desc": "[color=green]+8 Armor[/color]\n[color=red]-50 Move Speed[/color]", "rarity": "Legendary", "stats": [{"key": "armor", "amount": 8.0}, {"key": "speed", "amount": -50.0}]},
	{"name": "Glass Shard", "desc": "[color=green]+25% Damage[/color]\n[color=red]-10 Max HP[/color]", "rarity": "Common", "stats": [{"key": "might", "amount": 0.25}, {"key": "max_health", "amount": -10.0}]},
	{"name": "Old Map", "desc": "[color=green]+50% XP Gain[/color]\n[color=red]-20% Damage[/color]", "rarity": "Rare", "stats": [{"key": "growth", "amount": 0.5}, {"key": "might", "amount": -0.2}]},
	{"name": "Sun Stone", "desc": "[color=green]+20% Area[/color]\n[color=green]+0.2 HP/sec[/color]", "rarity": "Rare", "stats": [{"key": "area", "amount": 0.2}, {"key": "recovery", "amount": 0.2}]},
	{"name": "Moon Charm", "desc": "[color=green]+15% Attack Speed[/color]\n[color=green]+15% Luck[/color]", "rarity": "Rare", "stats": [{"key": "attack_speed_bonus", "amount": 0.15}, {"key": "luck", "amount": 0.15}]},
	{"name": "Dull Blade", "desc": "[color=green]+15 Armor[/color]\n[color=red]-40% Damage[/color]", "rarity": "Legendary", "stats": [{"key": "armor", "amount": 15.0}, {"key": "might", "amount": -0.4}]},
	{"name": "Fools Gold", "desc": "[color=green]+100% Luck[/color]\n[color=red]-40% XP Gain[/color]", "rarity": "Legendary", "stats": [{"key": "luck", "amount": 1.0}, {"key": "growth", "amount": -0.4}]},
	{"name": "Ancient Heart", "desc": "[color=green]+80 Max HP[/color]\n[color=red]-0.5 HP/sec Regen[/color]", "rarity": "Legendary", "stats": [{"key": "max_health", "amount": 80.0}, {"key": "recovery", "amount": -0.5}]}
]
