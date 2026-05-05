class_name UpgradeDatabase
extends Node

static var weapons_db = {
	"knife":
	{
		"name": "Knife",
		"desc": "[color=green]New Weapon[/color]\nThrows a fast, precise blade.",
		"rarity": "Common",
		"scene": preload("res://main/weapons/equipable_weapons/range/knife/knife_weapon.tscn"),
		"icon": preload("res://main/weapons/equipable_weapons/range/knife/knife.png")
	},
	"ice_aura":
	{
		"name": "Ice Aura",
		"desc": "[color=green]New Weapon[/color]\nSurrounds you with a freezing zone.",
		"rarity": "Uncommon",
		"unlock_req" :"runs_1",
		"scene": preload("res://main/weapons/equipable_weapons/aura/ice_aura/ice_aura.tscn"),
		"icon": preload("res://assets/art/icons/weapon_icon/ice_aura.png")
	},
	"chain_lightning":
	{
		"name": "Chain Lightning",
		"desc": "[color=green]New Weapon[/color]\nUnleashes a bouncing bolt of energy.",
		"rarity": "Rare",
		"scene": preload("res://main/weapons/equipable_weapons/other/chain_lightning/chain_lightning.tscn"),
		"icon": preload("res://assets/art/icons/weapon_icon/chain_lightning.png")
	},
	"pillar_of_light":
	{
		"name": "Pillar of Light",
		"desc": "[color=green]New Weapon[/color]\nSmites enemies with a divine strike.",
		"rarity": "Epic",
		"scene": preload("res://main/weapons/equipable_weapons/other/pillar_of_light/pillar_of_light.tscn"),
		"icon": preload("res://assets/art/icons/weapon_icon/pillar_of_light.png")
	},
	"void_orbs":
	{
		"name": "Void Orb",
		"desc": "[color=green]New Weapon[/color]\nSummons dark orbs that orbit you.",
		"rarity": "Legendary",
		"scene": preload("res://main/weapons/equipable_weapons/melee/void_orbs/void_orbs.tscn"),
		"icon": preload("res://assets/art/icons/weapon_icon/void_orbs.png")
	},
	"blood_trail":
	{
		"name": "Blood Trail",
		"desc": "[color=green]New Weapon[/color]\nLeaves a damaging path of blood behind.",
		"rarity": "Uncommon",
		"unlock_req": "kills_1k",
		"scene": preload("res://main/weapons/equipable_weapons/other/blood_trail/blood_trail.tscn"),
		"icon": preload("res://assets/art/icons/weapon_icon/blood_trail.png")
	},
	"phantom_glaive":
	{
		"name": "Phantom Glaive",
		"desc": "[color=green]New Weapon[/color]\nHurls a returning spectral blade.",
		"rarity": "Uncommon",
		"scene": preload("res://main/weapons/equipable_weapons/range/phantom_glaive/phantom_glaive.tscn"),
		"icon": preload("res://assets/art/icons/weapon_icon/phantom_glaive.png")
	},
	"abyssal_impale":
	{
		"name": "Abyssal Impale",
		"desc": "[color=green]New Weapon[/color]\nErupts lethal spikes from the ground.",
		"rarity": "Epic",
		"unlock_req": "survive_10_min",
		"scene": preload("res://main/weapons/equipable_weapons/other/abyssal_impale/abyssal_impale.tscn"),
		"icon": preload("res://assets/art/icons/weapon_icon/abyssal_impale.png")
	},
	"longsword":
	{
		"name": "Longsword",
		"desc": "[color=green]New Weapon[/color]\nCleaves through enemies with a wide swing.",
		"rarity": "Common",
		"unlock_req": "Crusader",
		"scene": preload("res://main/weapons/equipable_weapons/melee/longsword/longsword.tscn"),
		"icon": preload("res://assets/art/weapons/sword/sword.png")
	},
	"fireball":
	{
		"name": "Fireball",
		"desc": "[color=green]New Weapon[/color]\nFires a piercing fireball that burns enemies.",
		"rarity": "Rare",
		"unlock_req": "Wizard",
		"scene": preload("res://main/weapons/equipable_weapons/range/fireball/firewand.tscn"),
		"icon": preload("res://assets/art/weapons/fireball/fireball.png")
	},
	"firebomb":
	{
		"name": "Black Firebomb",
		"desc": "[color=green]New Weapon[/color]\nThrows explosive jars in a high arc.",
		"rarity": "Uncommon",
		"scene": preload("res://main/weapons/equipable_weapons/range/black_firebomb/firebomb_launcher.tscn"),
		"icon": preload("res://assets/art/weapons/firebomb/firebomb.png")
	},
	"executioner_axe":
	{
		"name": "Executioner's Axe",
		"desc": "[color=green]New Weapon[/color]\nDelivers a devastating overhead chop.",
		"rarity": "Rare",
		"unlock_req": "Orc",
		"scene": preload("res://main/weapons/equipable_weapons/melee/executioner_axe/executioner_axe.tscn"),
		"icon": preload("res://assets/art/weapons/executioner_axe/executioner_axe.png")
	},
	"bow":
	{
		"name": "Bow",
		"desc": "[color=green]New Weapon[/color]\nShoots Arrows.",
		"rarity": "Common",
		"scene": preload("res://main/weapons/equipable_weapons/range/bow/bow.tscn"),
		"icon": preload("res://assets/art/weapons/bow/bow.png")
	},
	"dragons_breath":
	{
		"name": "Dragon's Breath",
		"desc": "[color=green]New Weapon[/color]\nUnleashes a devastating burst of flame in the direction you are moving.",
		"rarity": "Legendary",
		"scene": preload("res://main/weapons/equipable_weapons/range/dragons_breath/dragons_breath.tscn"),
		"icon": preload("res://assets/art/weapons/dragons_breath/dragons_breath.png")
	},
	"cursed_prism":
	{
		"name": "Cursed Prism",
		"desc": "[color=green]New Weapon[/color]\nDrops a stationary crystal that periodically shocks nearby enemies.",
		"rarity": "Uncommon",
		"scene": preload("res://main/weapons/equipable_weapons/other/prism_weapon/cursed_prism.tscn"),
		"icon": preload("res://assets/art/weapons/cursed_prism/prism_icon.png")
	},
	"holy_radiance":
	{
		"name": "Holy Radiance",
		"desc": "[color=green]New Weapon[/color]\nA pulsing ring of light that pushes enemies away.",
		"rarity": "Uncommon",
		"scene": preload("res://main/weapons/equipable_weapons/aura/holy_radiance/holy_radiance.tscn"),
		"icon": preload("res://assets/art/icons/weapon_icon/holy_radiance.png")
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
		"desc": "[color=green]+5% Damage[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "might", "amount": 0.05}]
	},
	{
		"name": "Whetstone",
		"desc": "[color=green]+10% Damage[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "might", "amount": 0.10}]
	},
	{
		"name": "Soldier's Grit",
		"desc": "[color=green]+8% Damage[/color]\n[color=green]+10 Max Health[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "might", "amount": 0.08}, {"key": "max_health", "amount": 10.0}]
	},
	{
		"name": "Heavy Edge",
		"desc": "[color=green]+15% Damage[/color]\n[color=red]-10 Move Speed[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "might", "amount": 0.15}, {"key": "speed", "amount": -10.0}]
	},
	{
		"name": "Executioner",
		"desc": "[color=green]+20% Damage[/color]\n[color=red]-5% Attack Speed[/color]",
		"rarity": "Rare",
		"type": "stat",
		"unlock_req": "Orc",
		"stats": [{"key": "might", "amount": 0.20}, {"key": "attack_speed_bonus", "amount": -0.05}]
	},
	{
		"name": "Cursed Edge",
		"desc": "[color=green]+30% Damage[/color]\n[color=red]-3 Armor[/color]",
		"rarity": "Epic",
		"type": "stat",
		"unlock_req": "dmg_100k",
		"stats": [{"key": "might", "amount": 0.30}, {"key": "armor", "amount": -3.0}]
	},
	{
		"name": "Glass Cannon",
		"desc": "[color=green]+45% Damage[/color]\n[color=red]-30 Max Health[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"unlock_req": "survive_20_min",
		"stats": [{"key": "might", "amount": 0.45}, {"key": "max_health", "amount": -30.0}]
	},
	{
		"name": "Pact of the Void",
		"desc": "[color=green]+60% Damage[/color]\n[color=red]-50 Max Health[/color]\n[color=red]-2 Armor[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"unlock_req": "kills_10k",
		"stats": [
			{"key": "might", "amount": 0.60}, 
			{"key": "max_health", "amount": -50.0},
			{"key": "armor", "amount": -2.0}
		]
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
		"stats": [{"key": "attack_speed_bonus", "amount": 0.10}]
	},
	{
		"name": "Light Weapon",
		"desc": "[color=green]+15% Attack Speed[/color]\n[color=red]-5% Damage[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "attack_speed_bonus", "amount": 0.15}, {"key": "might", "amount": -0.05}]
	},
	{
		"name": "Frenzy",
		"desc": "[color=green]+25% Attack Speed[/color]\n[color=red]-10% Area[/color]",
		"rarity": "Epic",
		"type": "stat",
		"unlock_req": "level_50",
		"stats": [{"key": "attack_speed_bonus", "amount": 0.25}, {"key": "area", "amount": -0.10}]
	},
	{
		"name": "Lightning Strikes",
		"desc": "[color=green]+40% Attack Speed[/color]\n[color=red]-15% Damage[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"unlock_req": "level_100",
		"stats": [{"key": "attack_speed_bonus", "amount": 0.40}, {"key": "might", "amount": -0.15}]
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
		"desc": "[color=green]+15 Max Health[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "max_health", "amount": 15.0}]
	},
	{
		"name": "Iron Plate",
		"desc": "[color=green]+2 Armor[/color]\n[color=red]-5 Move Speed[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "armor", "amount": 2.0}, {"key": "speed", "amount": -5.0}]
	},
	{
		"name": "Troll Blood",
		"desc": "[color=green]+0.5 HP/sec Regen[/color]",
		"rarity": "Rare",
		"type": "stat",
		"unlock_req": "runs_10",
		"stats": [{"key": "recovery", "amount": 0.5}]
	},
	{
		"name": "Stone Skin",
		"desc": "[color=green]+4 Armor[/color]\n[color=red]-10% Area[/color]",
		"rarity": "Rare",
		"type": "stat",
		"unlock_req": "Crusader",
		"stats": [{"key": "armor", "amount": 4.0}, {"key": "area", "amount": -0.10}]
	},
	{
		"name": "Heavy Plate",
		"desc": "[color=green]+6 Armor[/color]\n[color=red]-15 Move Speed[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [{"key": "armor", "amount": 6.0}, {"key": "speed", "amount": -15.0}]
	},
	{
		"name": "Undying Will",
		"desc": "[color=green]+60 Max Health[/color]\n[color=green]+1.0 HP/sec Regen[/color]\n[color=red]-20% Damage[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"unlock_req": "survive_30_min",
		"stats": [
			{"key": "max_health", "amount": 60.0}, 
			{"key": "recovery", "amount": 1.0},
			{"key": "might", "amount": -0.20}
		]
	},
	{
		"name": "Juggernaut",
		"desc": "[color=green]+10 Armor[/color]\n[color=red]-30 Move Speed[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"unlock_req": "runs_50",
		"stats": [{"key": "armor", "amount": 10.0}, {"key": "speed", "amount": -30.0}]
	},

	# ==========================================
	# --- SPEED & AREA ---
	# ==========================================
	{
		"name": "Wider Reach",
		"desc": "[color=green]+10% Area[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "area", "amount": 0.10}]
	},
	{
		"name": "Swift Boots",
		"desc": "[color=green]+15 Move Speed[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "speed", "amount": 15.0}]
	},
	{
		"name": "Great Swing",
		"desc": "[color=green]+15% Area[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "area", "amount": 0.15}]
	},
	{
		"name": "Titan's Ring",
		"desc": "[color=green]+25% Area[/color]\n[color=red]-10 Move Speed[/color]",
		"rarity": "Rare",
		"type": "stat",
		"unlock_req": "kills_1k",
		"stats": [{"key": "area", "amount": 0.25}, {"key": "speed", "amount": -10.0}]
	},
	{
		"name": "Expanding Force",
		"desc": "[color=green]+35% Area[/color]\n[color=red]-10% Attack Speed[/color]",
		"rarity": "Epic",
		"type": "stat",
		"unlock_req": "dmg_1M",
		"stats": [{"key": "area", "amount": 0.35}, {"key": "attack_speed_bonus", "amount": -0.10}]
	},
	{
		"name": "Wind Walker",
		"desc": "[color=green]+30 Move Speed[/color]\n[color=red]-1 Armor[/color]",
		"rarity": "Epic",
		"type": "stat",
		"unlock_req": "survive_20_min",
		"stats": [{"key": "speed", "amount": 30.0}, {"key": "armor", "amount": -1.0}]
	},
	{
		"name": "Black Hole",
		"desc": "[color=green]+50% Area[/color]\n[color=red]-20% Attack Speed[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"unlock_req": "kills_100k",
		"stats": [{"key": "area", "amount": 0.50}, {"key": "attack_speed_bonus", "amount": -0.20}]
	},

	# ==========================================
	# --- UTILITY (MAGNET, GROWTH, LUCK) ---
	# ==========================================
	{
		"name": "Small Clover",
		"desc": "[color=green]+10% Luck[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "luck", "amount": 0.10}]
	},
	{
		"name": "Attractor",
		"desc": "[color=green]+20% Pickup Range[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "magnet_mult", "amount": 0.20}]
	},
	{
		"name": "Scholar",
		"desc": "[color=green]+15% XP Gain[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"unlock_req": "Wizard",
		"stats": [{"key": "growth", "amount": 0.15}]
	},
	{
		"name": "Curiosity",
		"desc": "[color=green]+15% Luck[/color]\n[color=green]+10% XP[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "luck", "amount": 0.15}, {"key": "growth", "amount": 0.10}]
	},
	{
		"name": "Magnetic Soul",
		"desc": "[color=green]+40% Pickup Range[/color]\n[color=red]-5 Move Speed[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "magnet_mult", "amount": 0.40}, {"key": "speed", "amount": -5.0}]
	},
	{
		"name": "Wisdom",
		"desc": "[color=green]+30% XP Gain[/color]\n[color=red]-5% Damage[/color]",
		"rarity": "Epic",
		"type": "stat",
		"unlock_req": "level_50",
		"stats": [{"key": "growth", "amount": 0.30}, {"key": "might", "amount": -0.05}]
	},
	{
		"name": "Greed",
		"desc": "[color=green]+40% XP Gain[/color]\n[color=red]-20% Luck[/color]",
		"rarity": "Epic",
		"type": "stat",
		"unlock_req": "gold_10k",
		"stats": [{"key": "growth", "amount": 0.40}, {"key": "luck", "amount": -0.20}]
	},
	{
		"name": "Midas Touch",
		"desc": "[color=green]+100% Luck[/color]\n[color=red]-3 Armor[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"unlock_req": "gold_100k",
		"stats": [{"key": "luck", "amount": 1.0}, {"key": "armor", "amount": -3.0}]
	},

	# ==========================================
	# --- BLOOD MAGIC (Trade-offs) ---
	# ==========================================
	{
		"name": "Rusty Scalpel",
		"desc": "[color=green]+10% Damage[/color]\n[color=red]-5 Max Health[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "might", "amount": 0.10}, {"key": "max_health", "amount": -5.0}]
	},
	{
		"name": "Blood Price",
		"desc": "[color=green]+20% Damage[/color]\n[color=red]-10 Max Health[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"unlock_req": "kills_100",
		"stats": [{"key": "might", "amount": 0.20}, {"key": "max_health", "amount": -10.0}]
	},
	{
		"name": "Flesh Sacrifice",
		"desc": "[color=green]+30% Area[/color]\n[color=red]-15 Max Health[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "area", "amount": 0.30}, {"key": "max_health", "amount": -15.0}]
	},
	{
		"name": "Vampire's Hunger",
		"desc": "[color=green]+2.0 HP/sec Regen[/color]\n[color=red]-20% XP Gain[/color]",
		"rarity": "Epic",
		"type": "stat",
		"unlock_req": "survive_10_min",
		"stats": [{"key": "recovery", "amount": 2.0}, {"key": "growth", "amount": -0.20}]
	},
	{
		"name": "Blood Boiling",
		"desc": "[color=green]+35% Damage[/color]\n[color=green]+35% Attack Speed[/color]\n[color=red]-40 Max Health[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"unlock_req": "kills_1M",
		"stats": [
			{"key": "might", "amount": 0.35},
			{"key": "attack_speed_bonus", "amount": 0.35},
			{"key": "max_health", "amount": -40.0}
		]
	},
	# ==========================================
	# --- NEW COMBAT UTILITY (Balanced Offense) ---
	# ==========================================
	{
		"name": "Duelist's Grip",
		"desc": "[color=green]+10% Damage[/color]\n[color=green]+10% Attack Speed[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "might", "amount": 0.10}, {"key": "attack_speed_bonus", "amount": 0.10}]
	},
	{
		"name": "Heavy Stance",
		"desc": "[color=green]+15% Damage[/color]\n[color=green]+2 Armor[/color]\n[color=red]-10 Move Speed[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [
			{"key": "might", "amount": 0.15}, 
			{"key": "armor", "amount": 2.0}, 
			{"key": "speed", "amount": -10.0}
		]
	},
	{
		"name": "Ruthless Precision",
		"desc": "[color=green]+25% Damage[/color]\n[color=red]-15% Area[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "might", "amount": 0.25}, {"key": "area", "amount": -0.15}]
	},
	{
		"name": "Sweeping Strikes",
		"desc": "[color=green]+20% Area[/color]\n[color=green]+10% Damage[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "area", "amount": 0.20}, {"key": "might", "amount": 0.10}]
	},
	{
		"name": "Warlord's Command",
		"desc": "[color=green]+30% Area[/color]\n[color=green]+20% Attack Speed[/color]\n[color=red]-2 Armor[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [
			{"key": "area", "amount": 0.30}, 
			{"key": "attack_speed_bonus", "amount": 0.20}, 
			{"key": "armor", "amount": -2.0}
		]
	},
	{
		"name": "Overclock",
		"desc": "[color=green]+40% Attack Speed[/color]\n[color=red]-20% Area[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [{"key": "attack_speed_bonus", "amount": 0.40}, {"key": "area", "amount": -0.20}]
	},
	{
		"name": "Colossal Impact",
		"desc": "[color=green]+50% Area[/color]\n[color=green]+30% Damage[/color]\n[color=red]-30% Attack Speed[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"unlock_req": "dmg_1M",
		"stats": [
			{"key": "area", "amount": 0.50}, 
			{"key": "might", "amount": 0.30}, 
			{"key": "attack_speed_bonus", "amount": -0.30}
		]
	},

	# ==========================================
	# --- SURVIVAL SPECIALISTS (Defensive & Movement) ---
	# ==========================================
	{
		"name": "Sturdy Boots",
		"desc": "[color=green]+10 Move Speed[/color]\n[color=green]+1 Armor[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "speed", "amount": 10.0}, {"key": "armor", "amount": 1.0}]
	},
	{
		"name": "Runner's Lungs",
		"desc": "[color=green]+20 Move Speed[/color]\n[color=green]+0.2 HP/sec Regen[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "speed", "amount": 20.0}, {"key": "recovery", "amount": 0.2}]
	},
	{
		"name": "Spiked Armor",
		"desc": "[color=green]+3 Armor[/color]\n[color=green]+5% Damage[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "armor", "amount": 3.0}, {"key": "might", "amount": 0.05}]
	},
	{
		"name": "Fortitude",
		"desc": "[color=green]+20 Max Health[/color]\n[color=green]+2 Armor[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "max_health", "amount": 20.0}, {"key": "armor", "amount": 2.0}]
	},
	{
		"name": "Nimble Fighter",
		"desc": "[color=green]+30 Move Speed[/color]\n[color=green]+15% Attack Speed[/color]\n[color=red]-10 Max Health[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [
			{"key": "speed", "amount": 30.0}, 
			{"key": "attack_speed_bonus", "amount": 0.15}, 
			{"key": "max_health", "amount": -10.0}
		]
	},
	{
		"name": "Regrowth",
		"desc": "[color=green]+1.0 HP/sec Regen[/color]\n[color=green]+30 Max Health[/color]\n[color=red]-10% Damage[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [
			{"key": "recovery", "amount": 1.0}, 
			{"key": "max_health", "amount": 30.0}, 
			{"key": "might", "amount": -0.10}
		]
	},
	{
		"name": "Phalanx",
		"desc": "[color=green]+8 Armor[/color]\n[color=red]-20% Area[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [{"key": "armor", "amount": 8.0}, {"key": "area", "amount": -0.20}]
	},
	{
		"name": "Impenetrable",
		"desc": "[color=green]+12 Armor[/color]\n[color=green]+50 Max Health[/color]\n[color=red]-40 Move Speed[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"unlock_req": "survive_60_min",
		"stats": [
			{"key": "armor", "amount": 12.0}, 
			{"key": "max_health", "amount": 50.0}, 
			{"key": "speed", "amount": -40.0}
		]
	},

	# ==========================================
	# --- LOOTERS & SCHOLARS (Economy & Growth) ---
	# ==========================================
	{
		"name": "Lucky Coin",
		"desc": "[color=green]+15% Luck[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "luck", "amount": 0.15}]
	},
	{
		"name": "Wide Net",
		"desc": "[color=green]+25% Pickup Range[/color]\n[color=green]+5% Area[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "magnet_mult", "amount": 0.25}, {"key": "area", "amount": 0.05}]
	},
	{
		"name": "Apprentice's Notes",
		"desc": "[color=green]+10% XP Gain[/color]\n[color=green]+10% Pickup Range[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "growth", "amount": 0.10}, {"key": "magnet_mult", "amount": 0.10}]
	},
	{
		"name": "Scavenger",
		"desc": "[color=green]+40% Pickup Range[/color]\n[color=green]+10 Move Speed[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "magnet_mult", "amount": 0.40}, {"key": "speed", "amount": 10.0}]
	},
	{
		"name": "Blessed Runes",
		"desc": "[color=green]+25% Luck[/color]\n[color=green]+15% XP Gain[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [{"key": "luck", "amount": 0.25}, {"key": "growth", "amount": 0.15}]
	},
	{
		"name": "Knowledge is Power",
		"desc": "[color=green]+30% XP Gain[/color]\n[color=green]+15% Damage[/color]",
		"rarity": "Epic",
		"type": "stat",
		"unlock_req": "level_25",
		"stats": [{"key": "growth", "amount": 0.30}, {"key": "might", "amount": 0.15}]
	},
	{
		"name": "Omniscience",
		"desc": "[color=green]+100% Pickup Range[/color]\n[color=green]+50% XP Gain[/color]\n[color=red]-20% Attack Speed[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"unlock_req": "level_100",
		"stats": [
			{"key": "magnet_mult", "amount": 1.0}, 
			{"key": "growth", "amount": 0.50}, 
			{"key": "attack_speed_bonus", "amount": -0.20}
		]
	},

	# ==========================================
	# --- THE CURSED RELICS (Extreme Trade-offs) ---
	# ==========================================
	{
		"name": "Cursed Penny",
		"desc": "[color=green]+30% Luck[/color]\n[color=red]-1 Armor[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "luck", "amount": 0.30}, {"key": "armor", "amount": -1.0}]
	},
	{
		"name": "Fever Dream",
		"desc": "[color=green]+20 Move Speed[/color]\n[color=green]+20% Attack Speed[/color]\n[color=red]-0.5 HP/sec Regen[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [
			{"key": "speed", "amount": 20.0}, 
			{"key": "attack_speed_bonus", "amount": 0.20}, 
			{"key": "recovery", "amount": -0.5}
		]
	},
	{
		"name": "Hollow Shell",
		"desc": "[color=green]+5 Armor[/color]\n[color=red]-20 Max Health[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "armor", "amount": 5.0}, {"key": "max_health", "amount": -20.0}]
	},
	{
		"name": "Blood Magic",
		"desc": "[color=green]+40% Damage[/color]\n[color=red]-2.0 HP/sec Regen[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [{"key": "might", "amount": 0.40}, {"key": "recovery", "amount": -2.0}]
	},
	{
		"name": "Gluttony",
		"desc": "[color=green]+80 Max Health[/color]\n[color=red]-50% Pickup Range[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [{"key": "max_health", "amount": 80.0}, {"key": "magnet_mult", "amount": -0.50}]
	},
	{
		"name": "Fragile Speed",
		"desc": "[color=green]+60 Move Speed[/color]\n[color=red]-4 Armor[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [{"key": "speed", "amount": 60.0}, {"key": "armor", "amount": -4.0}]
	},
	{
		"name": "Abyssal Contract",
		"desc": "[color=green]+100% XP Gain[/color]\n[color=green]+50% Luck[/color]\n[color=red]-50% Damage[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"unlock_req": "runs_100",
		"stats": [
			{"key": "growth", "amount": 1.0}, 
			{"key": "luck", "amount": 0.50}, 
			{"key": "might", "amount": -0.50}
		]
	},
	{
		"name": "Martyr's Crown",
		"desc": "[color=green]+100% Damage[/color]\n[color=red]-4 Armor[/color]\n[color=red]-40 Max Health[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"unlock_req": "kills_100k",
		"stats": [
			{"key": "might", "amount": 1.0}, 
			{"key": "armor", "amount": -4.0}, 
			{"key": "max_health", "amount": -40.0}
		]
	},
	# ==========================================
	# --- THE SNIPER (Viel Schaden, kleiner Radius) ---
	# ==========================================
	{
		"name": "Focus",
		"desc": "[color=green]+10% Damage[/color]\n[color=red]-5% Area[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "might", "amount": 0.10}, {"key": "area", "amount": -0.05}]
	},
	{
		"name": "Eagle Eye",
		"desc": "[color=green]+20% Damage[/color]\n[color=green]+10% Attack Speed[/color]\n[color=red]-10% Area[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [
			{"key": "might", "amount": 0.20}, 
			{"key": "attack_speed_bonus", "amount": 0.10}, 
			{"key": "area", "amount": -0.10}
		]
	},
	{
		"name": "Assassin's Dagger",
		"desc": "[color=green]+30% Attack Speed[/color]\n[color=red]-15% Area[/color]",
		"rarity": "Rare",
		"type": "stat",
		"unlock_req": "kills_10k",
		"stats": [{"key": "attack_speed_bonus", "amount": 0.30}, {"key": "area", "amount": -0.15}]
	},
	{
		"name": "Pinpoint Accuracy",
		"desc": "[color=green]+50% Damage[/color]\n[color=red]-30% Area[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [{"key": "might", "amount": 0.50}, {"key": "area", "amount": -0.30}]
	},

	# ==========================================
	# --- THE VAMPIRE (Regeneration gegen HP/Schaden) ---
	# ==========================================
	{
		"name": "Vigor",
		"desc": "[color=green]+10 Max Health[/color]\n[color=green]+0.1 HP/sec Regen[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "max_health", "amount": 10.0}, {"key": "recovery", "amount": 0.1}]
	},
	{
		"name": "Vampiric Touch",
		"desc": "[color=green]+0.5 HP/sec Regen[/color]\n[color=red]-5% Damage[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "recovery", "amount": 0.5}, {"key": "might", "amount": -0.05}]
	},
	{
		"name": "Bloodstone",
		"desc": "[color=green]+1.5 HP/sec Regen[/color]\n[color=red]-15 Max Health[/color]",
		"rarity": "Rare",
		"type": "stat",
		"unlock_req": "survive_10_min",
		"stats": [{"key": "recovery", "amount": 1.5}, {"key": "max_health", "amount": -15.0}]
	},
	{
		"name": "Cursed Blood",
		"desc": "[color=green]+40% Damage[/color]\n[color=red]-1.0 HP/sec Regen[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "might", "amount": 0.40}, {"key": "recovery", "amount": -1.0}]
	},
	{
		"name": "Heart of the Swarm",
		"desc": "[color=green]+2.5 HP/sec Regen[/color]\n[color=green]+50% Attack Speed[/color]\n[color=red]-40 Max Health[/color]",
		"rarity": "Epic",
		"type": "stat",
		"unlock_req": "kills_100k",
		"stats": [
			{"key": "recovery", "amount": 2.5}, 
			{"key": "attack_speed_bonus", "amount": 0.50}, 
			{"key": "max_health", "amount": -40.0}
		]
	},

	# ==========================================
	# --- THE JOUSTER (Speed und Wucht) ---
	# ==========================================
	{
		"name": "Long Legs",
		"desc": "[color=green]+15 Move Speed[/color]\n[color=green]+5% Area[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "speed", "amount": 15.0}, {"key": "area", "amount": 0.05}]
	},
	{
		"name": "Sprinter",
		"desc": "[color=green]+25 Move Speed[/color]\n[color=green]+10% Attack Speed[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "speed", "amount": 25.0}, {"key": "attack_speed_bonus", "amount": 0.10}]
	},
	{
		"name": "Jousting Lance",
		"desc": "[color=green]+30 Move Speed[/color]\n[color=green]+20% Damage[/color]\n[color=red]-10% Attack Speed[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [
			{"key": "speed", "amount": 30.0}, 
			{"key": "might", "amount": 0.20}, 
			{"key": "attack_speed_bonus", "amount": -0.10}
		]
	},
	{
		"name": "Titan's Stride",
		"desc": "[color=green]+50 Move Speed[/color]\n[color=green]+50% Area[/color]\n[color=red]-20% Attack Speed[/color]",
		"rarity": "Epic",
		"type": "stat",
		"unlock_req": "runs_50",
		"stats": [
			{"key": "speed", "amount": 50.0}, 
			{"key": "area", "amount": 0.50}, 
			{"key": "attack_speed_bonus", "amount": -0.20}
		]
	},

	# ==========================================
	# --- THE ANVIL (Verteidigung pur) ---
	# ==========================================
	{
		"name": "Padded Armor",
		"desc": "[color=green]+2 Armor[/color]\n[color=red]-5 Move Speed[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "armor", "amount": 2.0}, {"key": "speed", "amount": -5.0}]
	},
	{
		"name": "Tough Skin",
		"desc": "[color=green]+5 Max Health[/color]\n[color=green]+1 Armor[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "max_health", "amount": 5.0}, {"key": "armor", "amount": 1.0}]
	},
	{
		"name": "Heavy Boots",
		"desc": "[color=green]+3 Armor[/color]\n[color=red]-15 Move Speed[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "armor", "amount": 3.0}, {"key": "speed", "amount": -15.0}]
	},
	{
		"name": "Iron Grip",
		"desc": "[color=green]+10% Damage[/color]\n[color=green]+2 Armor[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "might", "amount": 0.10}, {"key": "armor", "amount": 2.0}]
	},
	{
		"name": "Dwarven Shield",
		"desc": "[color=green]+6 Armor[/color]\n[color=green]+20 Max Health[/color]\n[color=red]-15 Move Speed[/color]",
		"rarity": "Rare",
		"type": "stat",
		"unlock_req": "level_25",
		"stats": [
			{"key": "armor", "amount": 6.0}, 
			{"key": "max_health", "amount": 20.0}, 
			{"key": "speed", "amount": -15.0}
		]
	},
	{
		"name": "Aegis",
		"desc": "[color=green]+10 Armor[/color]\n[color=green]+50 Max Health[/color]\n[color=red]-20% Damage[/color]",
		"rarity": "Epic",
		"type": "stat",
		"unlock_req": "dmg_10M",
		"stats": [
			{"key": "armor", "amount": 10.0}, 
			{"key": "max_health", "amount": 50.0}, 
			{"key": "might", "amount": -0.20}
		]
	},

	# ==========================================
	# --- THE HOARDER (Riesiger Magnet & XP) ---
	# ==========================================
	{
		"name": "Lucky Charm",
		"desc": "[color=green]+10% Luck[/color]\n[color=green]+5% Pickup Range[/color]",
		"rarity": "Common",
		"type": "stat",
		"stats": [{"key": "luck", "amount": 0.10}, {"key": "magnet_mult", "amount": 0.05}]
	},
	{
		"name": "Merchant's Ledger",
		"desc": "[color=green]+15% XP Gain[/color]\n[color=green]+15% Luck[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "growth", "amount": 0.15}, {"key": "luck", "amount": 0.15}]
	},
	{
		"name": "Rabbit's Foot",
		"desc": "[color=green]+25% Luck[/color]",
		"rarity": "Uncommon",
		"type": "stat",
		"stats": [{"key": "luck", "amount": 0.25}]
	},
	{
		"name": "Gladiator's Net",
		"desc": "[color=green]+30% Area[/color]\n[color=green]+20% Pickup Range[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "area", "amount": 0.30}, {"key": "magnet_mult", "amount": 0.20}]
	},
	{
		"name": "Magnetized Armor",
		"desc": "[color=green]+4 Armor[/color]\n[color=green]+50% Pickup Range[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [{"key": "armor", "amount": 4.0}, {"key": "magnet_mult", "amount": 0.50}]
	},
	{
		"name": "Scholar's Glass",
		"desc": "[color=green]+40% XP Gain[/color]\n[color=red]-2 Armor[/color]",
		"rarity": "Rare",
		"type": "stat",
		"unlock_req": "level_50",
		"stats": [{"key": "growth", "amount": 0.40}, {"key": "armor", "amount": -2.0}]
	},
	{
		"name": "Philosopher's Stone",
		"desc": "[color=green]+60% Luck[/color]\n[color=green]+60% XP Gain[/color]\n[color=red]-15% Damage[/color]",
		"rarity": "Epic",
		"type": "stat",
		"unlock_req": "gold_100k",
		"stats": [
			{"key": "luck", "amount": 0.60}, 
			{"key": "growth", "amount": 0.60}, 
			{"key": "might", "amount": -0.15}
		]
	},

	# ==========================================
	# --- MYTHICAL RARITIES (Game Breakers) ---
	# ==========================================
	{
		"name": "Demon Horn",
		"desc": "[color=green]+50% Damage[/color]\n[color=green]+20% Attack Speed[/color]\n[color=red]-5 Armor[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [
			{"key": "might", "amount": 0.50}, 
			{"key": "attack_speed_bonus", "amount": 0.20}, 
			{"key": "armor", "amount": -5.0}
		]
	},
	{
		"name": "Divine Blessing",
		"desc": "[color=green]+100 Max Health[/color]\n[color=green]+10 Armor[/color]\n[color=green]+3.0 HP/sec Regen[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"unlock_req": "survive_60_min",
		"stats": [
			{"key": "max_health", "amount": 100.0}, 
			{"key": "armor", "amount": 10.0}, 
			{"key": "recovery", "amount": 3.0}
		]
	},
	{
		"name": "The Flash",
		"desc": "[color=green]+150 Move Speed[/color]\n[color=green]+100% Attack Speed[/color]\n[color=red]-50% Area[/color]\n[color=red]-20 Max Health[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"unlock_req": "runs_100",
		"stats": [
			{"key": "speed", "amount": 150.0}, 
			{"key": "attack_speed_bonus", "amount": 1.0}, 
			{"key": "area", "amount": -0.50},
			{"key": "max_health", "amount": -20.0}
		]
	},
	{
		"name": "Meteorite",
		"desc": "[color=green]+150% Area[/color]\n[color=green]+100% Damage[/color]\n[color=red]-80 Move Speed[/color]\n[color=red]-50% Attack Speed[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"unlock_req": "dmg_100M",
		"stats": [
			{"key": "area", "amount": 1.50}, 
			{"key": "might", "amount": 1.0}, 
			{"key": "speed", "amount": -80.0},
			{"key": "attack_speed_bonus", "amount": -0.50}
		]
	},
	# ==========================================
	# --- THE CURSED RELICS (Extreme Trade-offs) ---
	# ==========================================
	{
		"name": "Glass Sword",
		"desc": "[color=green]+80% Damage[/color]\n[color=red]-10 Armor[/color]\n[color=red]-40 Max Health[/color]",
		"rarity": "Epic",
		"type": "stat",
		"unlock_req": "kills_10k",
		"stats": [
			{"key": "might", "amount": 0.80},
			{"key": "armor", "amount": -10.0},
			{"key": "max_health", "amount": -40.0}
		]
	},
	{
		"name": "Lead Boots",
		"desc": "[color=green]+15 Armor[/color]\n[color=red]-80 Move Speed[/color]\n[color=red]-20% Area[/color]",
		"rarity": "Epic",
		"type": "stat",
		"unlock_req": "survive_20_min",
		"stats": [
			{"key": "armor", "amount": 15.0},
			{"key": "speed", "amount": -80.0},
			{"key": "area", "amount": -0.20}
		]
	},
	{
		"name": "Cursed Telescope",
		"desc": "[color=green]+150% Area[/color]\n[color=red]-50% Attack Speed[/color]\n[color=red]-10 Move Speed[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [
			{"key": "area", "amount": 1.50},
			{"key": "attack_speed_bonus", "amount": -0.50},
			{"key": "speed", "amount": -10.0}
		]
	},
	{
		"name": "Machine Heart",
		"desc": "[color=green]+100% Attack Speed[/color]\n[color=red]-5.0 HP/sec Regen[/color]\n[color=red]-20 Max Health[/color]",
		"rarity": "Epic",
		"type": "stat",
		"unlock_req": "level_50",
		"stats": [
			{"key": "attack_speed_bonus", "amount": 1.0},
			{"key": "recovery", "amount": -5.0},
			{"key": "max_health", "amount": -20.0}
		]
	},
	{
		"name": "Parasitic Worm",
		"desc": "[color=green]+5.0 HP/sec Regen[/color]\n[color=red]-40% Damage[/color]\n[color=red]-20% Attack Speed[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [
			{"key": "recovery", "amount": 5.0},
			{"key": "might", "amount": -0.40},
			{"key": "attack_speed_bonus", "amount": -0.20}
		]
	},
	{
		"name": "Glutton's Purse",
		"desc": "[color=green]+300% Pickup Range[/color]\n[color=red]-50 Move Speed[/color]\n[color=red]-20% Area[/color]",
		"rarity": "Epic",
		"type": "stat",
		"unlock_req": "gold_10k",
		"stats": [
			{"key": "magnet_mult", "amount": 3.0},
			{"key": "speed", "amount": -50.0},
			{"key": "area", "amount": -0.20}
		]
	},
	{
		"name": "Gambler's Dice",
		"desc": "[color=green]+100% Luck[/color]\n[color=red]-15 Max Health[/color]\n[color=red]-1 Armor[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [
			{"key": "luck", "amount": 1.0},
			{"key": "max_health", "amount": -15.0},
			{"key": "armor", "amount": -1.0}
		]
	},
	{
		"name": "Fool's Gold",
		"desc": "[color=green]+150% XP Gain[/color]\n[color=red]-60% Luck[/color]\n[color=red]-20% Damage[/color]",
		"rarity": "Epic",
		"type": "stat",
		"unlock_req": "level_100",
		"stats": [
			{"key": "growth", "amount": 1.50},
			{"key": "luck", "amount": -0.60},
			{"key": "might", "amount": -0.20}
		]
	},

	# ==========================================
	# --- THE DEMONIC BARGAINS (Legendary Game-Breakers) ---
	# ==========================================
	{
		"name": "Deal with the Devil",
		"desc": "[color=green]+200% Damage[/color]\n[color=red]-80 Max Health[/color]\n[color=red]-10.0 HP/sec Regen[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"unlock_req": "dmg_10M",
		"stats": [
			{"key": "might", "amount": 2.0},
			{"key": "max_health", "amount": -80.0},
			{"key": "recovery", "amount": -10.0}
		]
	},
	{
		"name": "Absolute Zero",
		"desc": "[color=green]+20 Armor[/color]\n[color=green]+10.0 HP/sec Regen[/color]\n[color=red]-120 Move Speed[/color]\n[color=red]-60% Attack Speed[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"unlock_req": "survive_60_min",
		"stats": [
			{"key": "armor", "amount": 20.0},
			{"key": "recovery", "amount": 10.0},
			{"key": "speed", "amount": -120.0},
			{"key": "attack_speed_bonus", "amount": -0.60}
		]
	},
	{
		"name": "Singularity",
		"desc": "[color=green]+300% Area[/color]\n[color=red]-80% Damage[/color]\n[color=red]-80% Attack Speed[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"unlock_req": "kills_1M",
		"stats": [
			{"key": "area", "amount": 3.0},
			{"key": "might", "amount": -0.80},
			{"key": "attack_speed_bonus", "amount": -0.80}
		]
	},
	{
		"name": "Overdrive Coil",
		"desc": "[color=green]+200% Attack Speed[/color]\n[color=green]+100 Move Speed[/color]\n[color=red]-80% Area[/color]\n[color=red]-15 Armor[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"unlock_req": "runs_100",
		"stats": [
			{"key": "attack_speed_bonus", "amount": 2.0},
			{"key": "speed", "amount": 100.0},
			{"key": "area", "amount": -0.80},
			{"key": "armor", "amount": -15.0}
		]
	},
	{
		"name": "All or Nothing",
		"desc": "[color=green]+300% Luck[/color]\n[color=green]+200% XP Gain[/color]\n[color=red]-50 Max Health[/color]\n[color=red]-5 Armor[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"unlock_req": "gold_100k",
		"stats": [
			{"key": "luck", "amount": 3.0},
			{"key": "growth", "amount": 2.0},
			{"key": "max_health", "amount": -50.0},
			{"key": "armor", "amount": -5.0}
		]
	},

	# ==========================================
	# --- THE WEIRD ONES (Spezifische Kombinationen) ---
	# ==========================================
	{
		"name": "Spiked Shield",
		"desc": "[color=green]+4 Armor[/color]\n[color=green]+15% Damage[/color]\n[color=red]-10% Area[/color]",
		"rarity": "Rare",
		"type": "stat",
		"stats": [
			{"key": "armor", "amount": 4.0},
			{"key": "might", "amount": 0.15},
			{"key": "area", "amount": -0.10}
		]
	},
	{
		"name": "Blood Fueled",
		"desc": "[color=green]+30 Move Speed[/color]\n[color=green]+30% Attack Speed[/color]\n[color=red]-2.0 HP/sec Regen[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [
			{"key": "speed", "amount": 30.0},
			{"key": "attack_speed_bonus", "amount": 0.30},
			{"key": "recovery", "amount": -2.0}
		]
	},
	{
		"name": "Hermit's Shell",
		"desc": "[color=green]+10 Armor[/color]\n[color=red]-40% Pickup Range[/color]\n[color=red]-20% XP Gain[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [
			{"key": "armor", "amount": 10.0},
			{"key": "magnet_mult", "amount": -0.40},
			{"key": "growth", "amount": -0.20}
		]
	},
	{
		"name": "Berserker's Rage",
		"desc": "[color=green]+80% Damage[/color]\n[color=red]-20% Accuracy (Area)[/color]\n[color=red]-5 Armor[/color]",
		"rarity": "Epic",
		"type": "stat",
		"unlock_req": "Orc",
		"stats": [
			{"key": "might", "amount": 0.80},
			{"key": "area", "amount": -0.20},
			{"key": "armor", "amount": -5.0}
		]
	},
	{
		"name": "Fragile Mind",
		"desc": "[color=green]+100% XP Gain[/color]\n[color=red]-30 Max Health[/color]\n[color=red]-2.0 HP/sec Regen[/color]",
		"rarity": "Epic",
		"type": "stat",
		"unlock_req": "Wizard",
		"stats": [
			{"key": "growth", "amount": 1.0},
			{"key": "max_health", "amount": -30.0},
			{"key": "recovery", "amount": -2.0}
		]
	},
	{
		"name": "Gravity Well",
		"desc": "[color=green]+200% Pickup Range[/color]\n[color=red]-80 Move Speed[/color]\n[color=red]-20% Attack Speed[/color]",
		"rarity": "Epic",
		"type": "stat",
		"stats": [
			{"key": "magnet_mult", "amount": 2.0},
			{"key": "speed", "amount": -80.0},
			{"key": "attack_speed_bonus", "amount": -0.20}
		]
	},
	{
		"name": "Cosmic Dust",
		"desc": "[color=green]+100% Area[/color]\n[color=green]+100% Luck[/color]\n[color=red]-50% Damage[/color]\n[color=red]-10 Armor[/color]",
		"rarity": "Legendary",
		"type": "stat",
		"unlock_req": "dmg_100k",
		"stats": [
			{"key": "area", "amount": 1.0},
			{"key": "luck", "amount": 1.0},
			{"key": "might", "amount": -0.50},
			{"key": "armor", "amount": -10.0}
		]
	}
]
