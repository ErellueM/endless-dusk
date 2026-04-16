extends Control

@onready var gold_label = $TopBar/GoldBox/GoldLabel
@onready var char_grid = $TabContainer/Characters/GridContainer
@onready var selected_info_label = $TabContainer/Characters/SelectedCharInfo
@onready var start_button = $StartRunButton

@onready var stats_list = $TabContainer/Stats/ScrollContainer/VBoxContainer
@onready var armory_list = $TabContainer/Armory/ScrollContainer/VBoxContainer

var currently_selected_char_node = null

# Dummy Database for your Armory (You can expand this!)
var weapon_db = [
	{"name": "Crusader Sword", "desc": "Swings in a wide arc.", "dmg": 15, "icon": preload("res://assets/art/destructables/barrel/item_drops/coin.png")}, # Replace with real icons
	{"name": "Magic Wand", "desc": "Fires a homing projectile.", "dmg": 8, "icon": preload("res://assets/art/destructables/barrel/item_drops/coin.png")},
	{"name": "Holy Aura", "desc": "Burns nearby enemies.", "dmg": 5, "icon": preload("res://assets/art/destructables/barrel/item_drops/coin.png")}
]

func _ready():
	update_gold_display()
	
	# Setup Characters
	for char_card in char_grid.get_children():
		char_card.setup()
		char_card.character_clicked.connect(_on_character_card_clicked)
		if char_card.character_name == "Soilder":
			_on_character_card_clicked(char_card)
			
	populate_stats()
	populate_armory()

func update_gold_display():
	gold_label.text = str(Global.gold)

func _on_character_card_clicked(clicked_card):
	if clicked_card.is_unlocked:
		currently_selected_char_node = clicked_card
		selected_info_label.text = "Selected: " + clicked_card.character_name
		start_button.disabled = false
		start_button.text = "START RUN"
	else:
		selected_info_label.text = "Buy " + clicked_card.character_name + " for " + str(clicked_card.unlock_cost) + "G?"
		start_button.disabled = true
		start_button.text = "LOCKED"
		
		if Global.gold >= clicked_card.unlock_cost:
			Global.gold -= clicked_card.unlock_cost
			Global.unlocked_characters.append(clicked_card.character_name)
			Global.save_game()
			update_gold_display()
			clicked_card.setup()
			_on_character_card_clicked(clicked_card)

# --- NEW: POPULATE STATS ---
func populate_stats():
	# Clear placeholder children
	for child in stats_list.get_children():
		child.queue_free()
		
	add_stat_row("Total Runs Played:", str(Global.total_runs_played))
	add_stat_row("Total Kills:", str(Global.lifetime_total_kills))
	add_stat_row("Highest Survival Time:", str(int(Global.highest_survival_time)) + "s")
	
	# Add a divider
	var divider = ColorRect.new()
	divider.custom_minimum_size.y = 2
	divider.color = Color(0.3, 0.3, 0.3)
	stats_list.add_child(divider)
	
	var title = Label.new()
	title.text = "--- MONSTER KILLS ---"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_list.add_child(title)
	
	# List all monster kills
	for enemy_name in Global.lifetime_kills_by_type:
		var amount = Global.lifetime_kills_by_type[enemy_name]
		add_stat_row(enemy_name + ":", str(amount))

func add_stat_row(title: String, value: String):
	var row = HBoxContainer.new()
	
	var lbl_title = Label.new()
	lbl_title.text = title
	lbl_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(lbl_title)
	
	var lbl_val = Label.new()
	lbl_val.text = value
	lbl_val.modulate = Color("#fceda6") # Gold color
	row.add_child(lbl_val)
	
	stats_list.add_child(row)

# --- NEW: POPULATE ARMORY ---
func populate_armory():
	for child in armory_list.get_children():
		child.queue_free()
		
	for weapon in weapon_db:
		var row = HBoxContainer.new()
		
		var icon = TextureRect.new()
		icon.texture = weapon["icon"]
		icon.custom_minimum_size = Vector2(32, 32)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(icon)
		
		var text_vbox = VBoxContainer.new()
		text_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(text_vbox)
		
		var name_lbl = Label.new()
		name_lbl.text = weapon["name"] + " (Dmg: " + str(weapon["dmg"]) + ")"
		text_vbox.add_child(name_lbl)
		
		var desc_lbl = Label.new()
		desc_lbl.text = weapon["desc"]
		desc_lbl.modulate = Color(0.7, 0.7, 0.7)
		text_vbox.add_child(desc_lbl)
		
		armory_list.add_child(row)

func _on_start_run_button_pressed():
	if currently_selected_char_node and currently_selected_char_node.is_unlocked:
		Global.total_runs_played += 1
		Global.save_game()
		Global.selected_character_scene = currently_selected_char_node.character_scene
		SceneChanger.change_scene("res://maps/map_1.tscn")

func _on_back_button_pressed():
	# Go back via Generic Back Button (No logic needed here if your BackButton handles it)
	pass
