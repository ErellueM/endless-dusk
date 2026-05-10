extends CanvasLayer

@onready var card_container = $Control/VBoxContainer/MarginContainer/CardContainer
@onready var title_label = $Control/VBoxContainer/Label
var card_scene = preload("res://main/ui/ingameUI/upgradeUI/UpgradeCard.tscn")

@export_group("Balancing & Loot Chances")
@export var debug_force_weapons: bool = false
@export_range(0.0, 1.0) var weapon_chance: float = 0.4
@export var weight_common: float = 70.0
@export var weight_uncommon: float = 50.0
@export var weight_rare: float = 25.0
@export var weight_epic: float = 10.0
@export var weight_legendary: float = 3.0

var remaining_picks: int = 1
var cards_to_generate: int = 3
var is_chest_mode: bool = false

func _ready():
	pass


func open_for_levelup():
	remaining_picks = 1
	cards_to_generate = 3
	is_chest_mode = false
	if title_label:
		title_label.text = "ASCENSION"
		title_label.show()
	generate_cards()
	show()

# Wird vom Grab-Skript aufgerufen
func open_for_chest(is_boss: bool):
	is_chest_mode = true
	if is_boss:
		remaining_picks = 2
		cards_to_generate = 5
	else:
		remaining_picks = 1
		cards_to_generate = 3
	if title_label:
		title_label.hide()
	generate_cards()
	show()


func get_weight(item: Dictionary, player_luck: float) -> float:
	var rarity = item.get("rarity", "Common")
	var item_type = item.get("type", "stat")
	var weight = 10.0
	var safe_luck = max(0.1, player_luck)

	match rarity:
		"Common":
			weight = weight_common / safe_luck
			
		"Uncommon":
			weight = weight_uncommon / sqrt(safe_luck)
			
		"Rare":
			weight = weight_rare * safe_luck
			
		"Epic":
			weight = weight_epic * (safe_luck * 1.2)
			
		"Legendary":
			weight = weight_legendary * (safe_luck * 1.5)

	if debug_force_weapons and (item_type == "weapon_upgrade" or item_type == "new_weapon"):
		return 99999.0

	return weight


func generate_cards():
	for child in card_container.get_children():
		child.queue_free()

	var player = get_tree().get_first_node_in_group("player")
	var weapons_manager = player.get_node_or_null("WeaponInventory") if player else null

	var stat_pool = []
	for stat_upg in UpgradeDatabase.stat_upgrades:
		if stat_upg.has("unlock_req"):
			var req = stat_upg["unlock_req"]
			if not Global.unlocked_achievements.has(req) and not Global.unlocked_characters.has(req):
				continue
			
		stat_pool.append(stat_upg)
	var weapon_pool = []

	var current_weapons = []
	var owned_weapon_ids = []

	if weapons_manager:
		current_weapons = weapons_manager.get_children()

		for w in current_weapons:
			if "weapon_id" in w:
				owned_weapon_ids.append(w.weapon_id)

				if w.level < w.max_level:
					var next_lvl = w.level + 1
					var upg_info = w.get_upgrade_info(next_lvl)

					weapon_pool.append(
						{
							"name": str(w.weapon_id).capitalize() + " Lvl " + str(next_lvl),
							"desc": upg_info["desc"],
							"rarity": upg_info["rarity"],
							"type": "weapon_upgrade",
							"weapon_node": w,
							"new_level": next_lvl,
							"icon": w.get("weapon_icon")  # Zieht das Icon direkt aus der ausgerüsteten Waffe
						}
					)

		if current_weapons.size() < weapons_manager.max_weapons:
			for w_id in UpgradeDatabase.weapons_db:
				if not owned_weapon_ids.has(w_id):
					var w_data = UpgradeDatabase.weapons_db[w_id]
					if w_data.has("unlock_req"):
						var req = w_data["unlock_req"]
						if not Global.unlocked_achievements.has(req) and not Global.unlocked_characters.has(req):
							continue
					weapon_pool.append(
						{
							"name": w_data["name"],
							"desc": w_data["desc"],
							"rarity": w_data.get("rarity", "Common"),
							"type": "new_weapon",
							"id": w_id,
							"scene": w_data["scene"],
							"icon": w_data.get("icon")  # Zieht das Icon aus der unowned_weapons_db
						}
					)

	var options = []
	var current_luck = player.luck if player and "luck" in player else 1.0

	var loop_failsafe = 0
	while options.size() < cards_to_generate and loop_failsafe < 100:
		loop_failsafe += 1

		var chosen_pool = stat_pool
		var roll_for_weapon = randf() < weapon_chance or debug_force_weapons

		if roll_for_weapon and weapon_pool.size() > 0:
			chosen_pool = weapon_pool
		elif stat_pool.size() == 0 and weapon_pool.size() > 0:
			chosen_pool = weapon_pool

		if chosen_pool.size() == 0:
			break

		var total_weight = 0.0
		for item in chosen_pool:
			if not options.has(item):
				total_weight += get_weight(item, current_luck)

		if total_weight <= 0.0:
			continue

		var random_roll = randf_range(0.0, total_weight)
		var current_sum = 0.0

		for item in chosen_pool:
			if not options.has(item):
				current_sum += get_weight(item, current_luck)
				if random_roll <= current_sum:
					options.append(item)
					break

	for i in options.size():
		var option = options[i]
		var card_instance = card_scene.instantiate()
		card_container.add_child(card_instance)

		var icon_tex = null
		var item_type = option.get("type", "stat")

		if item_type == "stat" and option.has("stats") and option["stats"].size() > 0:
			var primary_stat_key = option["stats"][0]["key"]
			icon_tex = UpgradeDatabase.stat_icons.get(primary_stat_key)
		elif item_type == "new_weapon" or item_type == "weapon_upgrade":
			icon_tex = option.get("icon", null)

		card_instance.set_item_data(option["name"], option["desc"], option["rarity"], icon_tex)
		card_instance.selected.connect(_on_upgrade_selected.bind(option, card_instance))
		card_instance.appear(i * 0.2)


func _on_upgrade_selected(option_data, card_instance):
	var player = get_tree().get_first_node_in_group("player")

	if player:
		var type = option_data.get("type", "stat")
		if type == "stat":
			apply_stat_upgrade(player, option_data)
			Global.discover_upgrade(option_data["name"])
			Global.add_run_upgrade(option_data["name"])

		elif type == "new_weapon":
			var weapons_manager = player.get_node("WeaponInventory")
			weapons_manager.add_weapon(option_data["scene"])

		elif type == "weapon_upgrade":
			var w_node = option_data["weapon_node"]
			if w_node.has_method("apply_level_upgrade"):
				w_node.apply_level_upgrade(option_data["new_level"])
	
	remaining_picks -= 1
	
	if is_instance_valid(card_instance):
		card_instance.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for child in card_instance.find_children("*", "BaseButton", true, false):
			child.disabled = true
		var fade = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		fade.tween_property(card_instance, "modulate:a", 0.0, 0.2) 
		#if remaining_picks > 0 and title_label:
			#title_label.text = "CHOOSE " + str(remaining_picks) + " MORE!"
			#title_label.show()
	
	if remaining_picks <= 0:
		var manager = get_tree().get_first_node_in_group("Managers")
		if manager:
			manager.change_state(manager.GameState.PLAYING)


func apply_stat_upgrade(player, data):
	if not data.has("stats"):
		return

	for stat in data["stats"]:
		var key = stat["key"]
		var amount = stat["amount"]

		match key:
			"luck":
				player.luck += amount
				
			"speed":
				player.speed = max(20.0, player.speed + amount)
				
			"armor":
				player.armor += amount
				
			"might":
				player.might = max(0.1, player.might + amount)
				
			"recovery":
				player.recovery += amount
				
			"area":
				player.area = max(0.1, player.area + amount)
				
			"attack_speed_bonus":
				player.attack_speed_bonus += amount
				
			"growth":
				player.growth = max(0.1, player.growth + amount)
				
			"magnet_mult":
				player.magnet_mult = max(0.0, player.magnet_mult + amount)
				if player.has_method("update_magnet"):
					player.update_magnet()
					
			"max_health":
				player.max_health = max(1.0, player.max_health + amount)
				if amount > 0:
					player.heal(amount, true)
			"magnet_mult":
				player.magnet_mult += amount
				if player.has_method("update_magnet"):
					player.update_magnet()
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
						player.health_changed.emit(
							player.health_component.current_health,
							player.health_component.max_health
						)
