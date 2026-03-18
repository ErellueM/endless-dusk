extends CanvasLayer

@onready var card_container = $Control/VBoxContainer/CardContainer
var card_scene = preload("res://main/ui/ingameUI/upgradeUI/UpgradeCard.tscn")

@export_group("Balancing & Debug")
# Wie viel wahrscheinlicher sind Waffen im Vergleich zu Stats? (Standard: 5x)
@export var weapon_weight_multiplier: float = 5.0 
# CHEAT-MODUS: Wenn an, kriegst du IMMER Waffen, bis das Inventar voll ist!
@export var debug_force_weapons: bool = false

# DATENBANK FÜR NEUE WAFFEN (Pfade anpassen!)
var unowned_weapons_db = {
	"knife": {
		"name": "Knife",
		"desc": "Throws a fast knife.",
		"scene": preload("res://main/weapons/equipable_weapons/range/knife/knife_weapon.tscn") # <--- DEIN PFAD
	},
	"ice_aura": {
		"name": "Ice Aura",
		"desc": "Creates a freezing zone.",
		"scene": preload("res://main/weapons/equipable_weapons/aura/ice_aura/ice_aura.tscn") # <--- DEIN PFAD
	}
}

# NEU: "stats" ist jetzt ein Array! So kannst du mehrere Werte gleichzeitig ändern.
var stat_upgrades = [
	# --- MIGHT (Damage) ---
	{"name": "Sharpen", "desc": "[color=green]+10% Damage[/color]", "rarity": "Common", "type": "stat", "stats": [{"key": "might", "amount": 0.1}]},
	{"name": "Brute Force", "desc": "[color=green]+25% Damage[/color]\n[color=red]-5% Attack Speed[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "might", "amount": 0.25}, {"key": "cooldown_mult", "amount": 0.05}]},
	{"name": "Glass Cannon", "desc": "[color=green]+50% Damage[/color]\n[color=red]-20 Max Health[/color]", "rarity": "Legendary", "type": "stat", "stats": [{"key": "might", "amount": 0.5}, {"key": "max_health", "amount": -20.0}]},

	# --- COOLDOWN (Attack Speed) ---
	{"name": "Quick Reflexes", "desc": "[color=green]+5% Attack Speed[/color]", "rarity": "Common", "type": "stat", "stats": [{"key": "cooldown_mult", "amount": -0.05}]},
	{"name": "Haste", "desc": "[color=green]+15% Attack Speed[/color]\n[color=red]-5% Damage[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "cooldown_mult", "amount": -0.15}, {"key": "might", "amount": -0.05}]},
	{"name": "Time Warp", "desc": "[color=green]+30% Attack Speed[/color]\n[color=red]-15% Damage[/color]", "rarity": "Legendary", "type": "stat", "stats": [{"key": "cooldown_mult", "amount": -0.30}, {"key": "might", "amount": -0.15}]},

	# --- HEALTH & RECOVERY ---
	{"name": "Minor Health", "desc": "[color=green]+10 Max Health[/color]", "rarity": "Common", "type": "stat", "stats": [{"key": "max_health", "amount": 10.0}]},
	{"name": "Troll Blood", "desc": "[color=green]+0.5 HP/sec Regen[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "recovery", "amount": 0.5}]},
	{"name": "Vampire Vial", "desc": "[color=green]+2.0 HP/sec Regen[/color]\n[color=red]-20 Max Health[/color]", "rarity": "Legendary", "type": "stat", "stats": [{"key": "recovery", "amount": 2.0}, {"key": "max_health", "amount": -20.0}]},

	# --- ARMOR ---
	{"name": "Leather Patch", "desc": "[color=green]+1 Armor[/color]", "rarity": "Common", "type": "stat", "stats": [{"key": "armor", "amount": 1.0}]},
	{"name": "Heavy Plate", "desc": "[color=green]+4 Armor[/color]\n[color=red]-10 Move Speed[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "armor", "amount": 4.0}, {"key": "speed", "amount": -10.0}]},
	{"name": "Juggernaut", "desc": "[color=green]+10 Armor[/color]\n[color=red]-30 Move Speed[/color]", "rarity": "Legendary", "type": "stat", "stats": [{"key": "armor", "amount": 10.0}, {"key": "speed", "amount": -30.0}]},

	# --- SPEED ---
	{"name": "Swift Boots", "desc": "[color=green]+20 Move Speed[/color]", "rarity": "Common", "type": "stat", "stats": [{"key": "speed", "amount": 20.0}]},
	{"name": "Wind Walker", "desc": "[color=green]+50 Move Speed[/color]\n[color=red]-2 Armor[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "speed", "amount": 50.0}, {"key": "armor", "amount": -2.0}]},

	# --- AREA (Size of Attacks) ---
	{"name": "Wider Reach", "desc": "[color=green]+10% Attack Area[/color]", "rarity": "Common", "type": "stat", "stats": [{"key": "area", "amount": 0.1}]},
	{"name": "Expanding Force", "desc": "[color=green]+30% Attack Area[/color]\n[color=red]-10% Attack Speed[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "area", "amount": 0.3}, {"key": "cooldown_mult", "amount": 0.1}]},

	# --- UTILITY (Magnet & XP) ---
	{"name": "Attractor", "desc": "[color=green]+25% Pickup Range[/color]", "rarity": "Common", "type": "stat", "stats": [{"key": "magnet_mult", "amount": 0.25}]},
	{"name": "Scholar", "desc": "[color=green]+15% XP Gain[/color]", "rarity": "Common", "type": "stat", "stats": [{"key": "growth", "amount": 0.15}]},
	{"name": "Greed", "desc": "[color=green]+40% Pickup Range[/color]\n[color=green]+30% XP Gain[/color]\n[color=red]-15% Luck[/color]", "rarity": "Legendary", "type": "stat", "stats": [{"key": "magnet_mult", "amount": 0.4}, {"key": "growth", "amount": 0.3}, {"key": "luck", "amount": -0.15}]},

	# --- LUCK ---
	{"name": "Small Clover", "desc": "[color=green]+10% Luck[/color]", "rarity": "Common", "type": "stat", "stats": [{"key": "luck", "amount": 0.1}]},
	{"name": "Golden Horseshoe", "desc": "[color=green]+25% Luck[/color]", "rarity": "Rare", "type": "stat", "stats": [{"key": "luck", "amount": 0.25}]}
]

func _ready():
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
	if visible:
		generate_cards()

func get_weight(item: Dictionary, player_luck: float) -> float:
	var rarity = item["rarity"]
	var item_type = item["type"]
	var weight = 10.0
	
	match rarity:
		"Common": weight = 70.0 
		"Rare": weight = 25.0 * player_luck 
		"Legendary": weight = 5.0 * (player_luck * 1.5) 
		
	# --- DIE MAGIE FÜR WAFFEN & DEN CHEAT ---
	if item_type == "weapon_upgrade" or item_type == "new_weapon":
		if debug_force_weapons:
			return 99999.0 # CHEAT: Macht die Waffe quasi zur 100% Garantie!
		else:
			weight *= weapon_weight_multiplier # Normales Balancing
			
	return weight

func generate_cards():
	for child in card_container.get_children():
		child.queue_free()
		
	var player = get_tree().get_first_node_in_group("player")
	var weapons_manager = player.get_node_or_null("WeaponInventory") if player else null
	
	var dynamic_pool = stat_upgrades.duplicate()
	var current_weapons = []
	var owned_weapon_ids = []
	
	if weapons_manager:
		current_weapons = weapons_manager.get_children()
		
		# 1. UPGRADES FÜR BESTEHENDE WAFFEN
		for w in current_weapons:
			if "weapon_id" in w:
				owned_weapon_ids.append(w.weapon_id)
				
				if w.level < w.max_level:
					var next_lvl = w.level + 1
					var upg_info = w.get_upgrade_info(next_lvl)
					
					dynamic_pool.append({
						"name": str(w.weapon_id).capitalize() + " Lvl " + str(next_lvl),
						"desc": upg_info["desc"],
						"rarity": upg_info["rarity"],
						"type": "weapon_upgrade",
						"weapon_node": w,
						"new_level": next_lvl
					})

		# 2. NEUE WAFFEN HINZUFÜGEN (Wenn Inventar Platz hat)
		if current_weapons.size() < weapons_manager.max_weapons:
			for w_id in unowned_weapons_db:
				if not owned_weapon_ids.has(w_id):
					var w_data = unowned_weapons_db[w_id]
					dynamic_pool.append({
						"name": "New: " + w_data["name"],
						"desc": w_data["desc"],
						"rarity": "Common",
						"type": "new_weapon",
						"id": w_id,
						"scene": w_data["scene"]
					})

	# 3. KARTEN ZIEHEN
	var options = []
	var current_luck = player.luck if player and "luck" in player else 1.0
	var loop_failsafe = 0
	
	while options.size() < 3 and dynamic_pool.size() > 0 and loop_failsafe < 100:
		loop_failsafe += 1
		var total_weight = 0.0
		for item in dynamic_pool:
			if options.has(item): continue 
			# HIER ÄNDERN: Einfach 'item' übergeben!
			total_weight += get_weight(item, current_luck) 
			
		var random_roll = randf_range(0.0, total_weight)
		var current_sum = 0.0
		
		for item in dynamic_pool:
			if options.has(item): continue
			# HIER ÄNDERN: Einfach 'item' übergeben!
			current_sum += get_weight(item, current_luck) 
			if random_roll <= current_sum:
				options.append(item)
				break

	# 4. KARTEN ANZEIGEN
	for i in options.size():
		var option = options[i]
		var card_instance = card_scene.instantiate()
		card_container.add_child(card_instance)
		card_instance.set_item_data(option["name"], option["desc"], option["rarity"])
		card_instance.selected.connect(_on_upgrade_selected.bind(option))
		card_instance.appear(i * 0.2)


func _on_upgrade_selected(option_data):
	var player = get_tree().get_first_node_in_group("player")
	
	if player:
		if option_data["type"] == "stat":
			apply_stat_upgrade(player, option_data)
			
		elif option_data["type"] == "new_weapon":
			var weapons_manager = player.get_node("WeaponInventory")
			weapons_manager.add_weapon(option_data["scene"])
			
		elif option_data["type"] == "weapon_upgrade":
			var w_node = option_data["weapon_node"]
			if w_node.has_method("apply_level_upgrade"):
				w_node.apply_level_upgrade(option_data["new_level"])
	
	var manager = get_tree().get_first_node_in_group("Managers")
	if manager:
		manager.change_state(manager.GameState.PLAYING)

# NEU: Verarbeitet jetzt das Array mit mehreren Stats!
func apply_stat_upgrade(player, data):
	for stat in data["stats"]:
		var key = stat["key"]
		var amount = stat["amount"]
		
		match key:
			"luck": player.luck += amount 
			"speed": player.speed += amount
			"armor": player.armor += amount
			"might": player.might += amount
			"recovery": player.recovery += amount
			"area": player.area += amount
			"cooldown_mult": player.cooldown_mult += amount
			"growth": player.growth += amount
			"magnet_mult": 
				player.magnet_mult += amount
				if player.has_method("update_magnet"): player.update_magnet()
			"max_health":
				if player.health_component:
					player.health_component.max_health += amount
					# Heile den Spieler um den Betrag, ziehe ihn bei Minus-Werten ab
					player.health_component.current_health += amount 
					# Verhindere, dass Health über Max steigt
					if player.health_component.current_health > player.health_component.max_health:
						player.health_component.current_health = player.health_component.max_health
					player.health_changed.emit(player.health_component.current_health, player.health_component.max_health)
