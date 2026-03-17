extends CanvasLayer

@onready var card_container = $Control/VBoxContainer/CardContainer

var card_scene = preload("res://main/ui/ingameUI/upgradeUI/UpgradeCard.tscn")

var weapon_upgrades = [
	{"name": "Axe", "desc": "Throws an axe in a high arc.", "rarity": "Common", "type": "weapon", "id": "axe"},
	{"name": "Fireball", "desc": "Shoots a fireball towards enemies.", "rarity": "Legendary", "type": "weapon", "id": "fireball"},
	{"name": "Magic Wand", "desc": "Fires a homing magic missile.", "rarity": "Rare", "type": "weapon", "id": "wand"}
]

var stat_upgrades = [
	# --- NEU: LUCK (Glück) UPGRADES ---
	{"name": "Small Clover", "desc": "+10% Luck", "rarity": "Common", "type": "stat", "stat_key": "luck", "amount": 0.1},
	{"name": "Golden Horseshoe", "desc": "+25% Luck", "rarity": "Rare", "type": "stat", "stat_key": "luck", "amount": 0.25},
	{"name": "Leprechaun Hat", "desc": "+50% Luck", "rarity": "Legendary", "type": "stat", "stat_key": "luck", "amount": 0.5},
	
	# MAX HEALTH
	{"name": "Minor Health", "desc": "+10 Max Health", "rarity": "Common", "type": "stat", "stat_key": "max_health", "amount": 10.0},
	{"name": "Hearty Meal", "desc": "+25 Max Health", "rarity": "Rare", "type": "stat", "stat_key": "max_health", "amount": 25.0},
	{"name": "Giant's Heart", "desc": "+50 Max Health", "rarity": "Legendary", "type": "stat", "stat_key": "max_health", "amount": 50.0},
	
	# SPEED
	{"name": "Light Boots", "desc": "+10 Movement Speed", "rarity": "Common", "type": "stat", "stat_key": "speed", "amount": 10.0},
	{"name": "Swift Boots", "desc": "+20 Movement Speed", "rarity": "Rare", "type": "stat", "stat_key": "speed", "amount": 20.0},
	{"name": "Hermes' Sandals", "desc": "+40 Movement Speed", "rarity": "Legendary", "type": "stat", "stat_key": "speed", "amount": 40.0},
	
	# ARMOR 
	{"name": "Leather Patch", "desc": "+1 Armor", "rarity": "Common", "type": "stat", "stat_key": "armor", "amount": 1.0},
	{"name": "Iron Plating", "desc": "+2 Armor", "rarity": "Rare", "type": "stat", "stat_key": "armor", "amount": 2.0},
	{"name": "Mithril Vest", "desc": "+4 Armor", "rarity": "Legendary", "type": "stat", "stat_key": "armor", "amount": 4.0},
	
	# RECOVERY 
	{"name": "Bandage", "desc": "+0.2 HP/sec", "rarity": "Common", "type": "stat", "stat_key": "recovery", "amount": 0.2},
	{"name": "Troll Blood", "desc": "+0.5 HP/sec", "rarity": "Rare", "type": "stat", "stat_key": "recovery", "amount": 0.5},
	
	# MIGHT 
	{"name": "Sharpen", "desc": "+10% Damage", "rarity": "Common", "type": "stat", "stat_key": "might", "amount": 0.1},
	{"name": "Brute Force", "desc": "+25% Damage", "rarity": "Rare", "type": "stat", "stat_key": "might", "amount": 0.25},
	
	# AREA 
	{"name": "Wider Reach", "desc": "+10% Attack Area", "rarity": "Common", "type": "stat", "stat_key": "area", "amount": 0.1},
	{"name": "Expanding Force", "desc": "+25% Attack Area", "rarity": "Rare", "type": "stat", "stat_key": "area", "amount": 0.25},
	
	# COOLDOWN 
	{"name": "Quick Reflexes", "desc": "Attacks 5% Faster", "rarity": "Common", "type": "stat", "stat_key": "cooldown_mult", "amount": -0.05},
	{"name": "Haste", "desc": "Attacks 10% Faster", "rarity": "Rare", "type": "stat", "stat_key": "cooldown_mult", "amount": -0.1},
	
	# MAGNET RANGE
	{"name": "Small Magnet", "desc": "+15% Pickup Range", "rarity": "Common", "type": "stat", "stat_key": "magnet_mult", "amount": 0.15},
	{"name": "Attractor", "desc": "+30% Pickup Range", "rarity": "Rare", "type": "stat", "stat_key": "magnet_mult", "amount": 0.30},
	
	# GROWTH 
	{"name": "Fast Learner", "desc": "+10% XP Gain", "rarity": "Common", "type": "stat", "stat_key": "growth", "amount": 0.1},
	{"name": "Scholar", "desc": "+25% XP Gain", "rarity": "Rare", "type": "stat", "stat_key": "growth", "amount": 0.25}
]

func _ready():
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
	if visible:
		generate_cards()

# --- DIE NEUE LOOT-TABLE FUNKTION ---
func get_weight(rarity: String, player_luck: float) -> float:
	match rarity:
		"Common": 
			return 70.0 # Standard-Chance bleibt immer gleich
		"Rare": 
			return 25.0 * player_luck # Bei Luck 2.0 (200%) verdoppelt sich die Chance!
		"Legendary": 
			return 5.0 * (player_luck * 1.5) # Legendaries profitieren noch stärker von Glück!
	return 10.0

func generate_cards():
	for child in card_container.get_children():
		child.queue_free()
		
	var all_upgrades = weapon_upgrades + stat_upgrades
	var options = []
	
	# Hol dir das Glück vom Spieler
	var current_luck = 1.0
	var player = get_tree().get_first_node_in_group("player")
	if player and "luck" in player:
		current_luck = player.luck

	# Wir ziehen 3 einzigartige Karten
	var loop_failsafe = 0
	while options.size() < 3 and loop_failsafe < 100:
		loop_failsafe += 1
		
		# 1. Gesamtgewicht aller verbleibenden Karten berechnen
		var total_weight = 0.0
		for upgrade in all_upgrades:
			if options.has(upgrade): continue # Bereits gezogene Karten überspringen
			total_weight += get_weight(upgrade["rarity"], current_luck)
			
		# 2. Eine zufällige Zahl in diesem Gewicht würfeln
		var random_roll = randf_range(0.0, total_weight)
		var current_sum = 0.0
		
		# 3. Herausfinden, auf welche Karte die Zahl gefallen ist
		for upgrade in all_upgrades:
			if options.has(upgrade): continue
			
			current_sum += get_weight(upgrade["rarity"], current_luck)
			if random_roll <= current_sum:
				options.append(upgrade)
				break # Wir haben eine Karte gefunden! Stoppe diese Suche.
	
	# --- KARTEN ANZEIGEN ---
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
		elif option_data["type"] == "weapon":
			print("Weapon system placeholder: ", option_data["id"])
	
	var manager = get_tree().get_first_node_in_group("Managers")
	if manager:
		manager.change_state(manager.GameState.PLAYING)

func apply_stat_upgrade(player, data):
	var key = data["stat_key"]
	var amount = data["amount"]
	
	match key:
		"luck":
			player.luck += amount 
		"speed":
			player.speed += amount
		"armor":
			player.armor += amount
		"recovery":
			player.recovery += amount
		"might":
			player.might += amount
		"area":
			player.area += amount
		"cooldown_mult":
			player.cooldown_mult += amount
		"magnet_mult":
			player.magnet_mult += amount
			if player.has_method("update_magnet"):
				player.update_magnet()
		"growth":
			player.growth += amount
		"max_health":
			if player.health_component:
				player.health_component.max_health += amount
				player.health_component.current_health += amount 
				player.health_changed.emit(player.health_component.current_health, player.health_component.max_health)
	
	print("Stat upgraded! ", key, " increased by ", amount, ". Current luck is now: ", player.luck)
