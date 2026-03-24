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
		"rarity": "Common",
		"scene": preload("res://main/weapons/equipable_weapons/range/knife/knife_weapon.tscn") # <--- DEIN PFAD
	},
	"ice_aura": {
		"name": "Ice Aura",
		"desc": "Creates a freezing zone.",
		"rarity": "Common",
		"scene": preload("res://main/weapons/equipable_weapons/aura/ice_aura/ice_aura.tscn") # <--- DEIN PFAD
	},
	"chain_lightning": {
		"name": "Chain Lightning",
		"desc": "[color=green]New Weapon[/color]\nFires a bouncing bolt of energy.",
		"rarity": "Rare",
		"scene": preload("res://main/weapons/equipable_weapons/other/chain_lightning/chain_lightning.tscn")
	},
	"pillar_of_light": {
		"name": "Pillar of Light",
		"desc": "[color=green]New Weapon[/color]\nGod strikes the souls.",
		"rarity": "Rare",
		"scene": preload("res://main/weapons/equipable_weapons/other/pillar_of_light/pillar_of_light.tscn")
	},
	"void_orbs": {
		"name": "Void Orb",
		"desc": "[color=green]New Weapon[/color]\n ...",
		"rarity": "Legendary",
		"scene": preload("res://main/weapons/equipable_weapons/melee/void_orbs/void_orbs.tscn")
	},
	"blood_trail": {
		"name": "Blood Trail",
		"desc": "[color=green]New Weapon[/color]\n ...",
		"rarity": "Rare",
		"scene": preload("res://main/weapons/equipable_weapons/other/blood_trail/blood_trail.tscn")
	},
	"phantom_glaive": {
			"name": "Phantom Glaive",
			"desc": "[color=green]New Weapon[/color]\nThrows a spectral blade that returns to you.",
			"rarity": "Rare",
			"scene": preload("res://main/weapons/equipable_weapons/range/phantom_glaive/phantom_glaive.tscn")
		},
	"abyssal_impale": {
			"name": "Abyssal Impale",
			"desc": "[color=green]New Weapon[/color]\nSpikes outranging the ground.",
			"rarity": "Rare",
			"scene": preload("res://main/weapons/equipable_weapons/other/abyssal_impale/abyssal_impale.tscn")
		},
}



func _ready():
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
	if visible:
		generate_cards()

func get_weight(item: Dictionary, player_luck: float) -> float:
	var rarity = item.get("rarity", "Common")
	var item_type = item.get("type", "stat")
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
	
	var dynamic_pool = UpgradeDatabase.stat_upgrades.duplicate()
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
						"rarity": w_data.get("rarity", "Common"),
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
		var type = option_data.get("type", "stat")
		if type == "stat":
			apply_stat_upgrade(player, option_data)
			
		elif type == "new_weapon":
			var weapons_manager = player.get_node("WeaponInventory")
			weapons_manager.add_weapon(option_data["scene"])
			
		elif type == "weapon_upgrade":
			var w_node = option_data["weapon_node"]
			if w_node.has_method("apply_level_upgrade"):
				w_node.apply_level_upgrade(option_data["new_level"])
	
	var manager = get_tree().get_first_node_in_group("Managers")
	if manager:
		manager.change_state(manager.GameState.PLAYING)

# NEU: Verarbeitet jetzt das Array mit mehreren Stats!
func apply_stat_upgrade(player, data):
	if not data.has("stats"):
		return
		
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
			"attack_speed_bonus": player.attack_speed_bonus += amount
			"growth": player.growth += amount
			"magnet_mult": 
				player.magnet_mult += amount
				if player.has_method("update_magnet"): player.update_magnet()
			"max_health":
				if player.health_component:
					var old_max = player.health_component.max_health
					player.health_component.max_health = max(1.0, old_max + amount)
					
					if amount > 0:
						player.health_component.current_health += amount
						
					if player.health_component.current_health > player.health_component.max_health:
						player.health_component.current_health = player.health_component.max_health
						
					if player.health_component.current_health < 1.0:
						player.health_component.current_health = 1.0
						
					if player.has_signal("health_changed"):
						player.health_changed.emit(player.health_component.current_health, player.health_component.max_health)
