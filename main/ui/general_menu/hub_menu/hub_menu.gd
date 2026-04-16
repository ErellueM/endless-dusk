extends Control

@onready var gold_label = $TopBar/GoldBox/GoldLabel
@onready var char_grid = $TabContainer/Characters/GridContainer
@onready var selected_info_label = $TabContainer/Characters/SelectedCharInfo
@onready var start_button = $StartRunButton

@onready var stats_list = $TabContainer/Stats/ScrollContainer/VBoxContainer
@onready var armory_list = $TabContainer/Armory/ScrollContainer/VBoxContainer

var currently_selected_char_node = null

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

# --- HELPER: FORMAT NUMBERS (Removes .0) ---
func _format_num(val: float) -> String:
	if fmod(val, 1.0) == 0.0:
		return str(int(val)) # Return as integer if it ends in .0
	return "%.1f" % val # Return with 1 decimal if it has fractions

# --- POPULATE STATS ---
func populate_stats():
	for child in stats_list.get_children():
		child.queue_free()
		
	# --- GENERAL STATS ---
	add_stat_row("Total Runs Played:", str(Global.total_runs_played))
	add_stat_row("Total Kills:", str(Global.lifetime_total_kills))
	add_stat_row("Highest Survival Time:", str(int(Global.highest_survival_time)) + "s")
	add_stat_row("Total Gold Earned:", str(Global.total_gold_earned))
	
	# Divider
	var divider = ColorRect.new()
	divider.custom_minimum_size.y = 2
	divider.color = Color(0.3, 0.3, 0.3)
	stats_list.add_child(divider)
	
	# --- MONSTER CATEGORIES ---
	var categories = ["Swarm", "Normal", "Miniboss", "Boss"]
	var category_titles = {
		"Swarm": "--- SWARM ENEMIES ---",
		"Normal": "--- NORMAL ENEMIES ---",
		"Miniboss": "--- MINIBOSSES ---",
		"Boss": "--- BOSSES ---"
	}
	
	for cat in categories:
		var kills_in_this_cat = []
		for enemy_name in Global.lifetime_kills_by_type:
			if Global.monsters_db.has(enemy_name) and Global.monsters_db[enemy_name]["category"] == cat:
				kills_in_this_cat.append(enemy_name)
				
		if kills_in_this_cat.size() > 0:
			var title = Label.new()
			title.text = "\n" + category_titles[cat]
			title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			title.modulate = Color(0.6, 0.6, 0.6)
			stats_list.add_child(title)
			
			for enemy_name in kills_in_this_cat:
				var amount = Global.lifetime_kills_by_type[enemy_name]
				var stat_text = str(amount) + " Killed"
				var m_icon = null
				var m_color = Color.WHITE
				
				var m_scene = Global.monsters_db[enemy_name]["scene"]
				var temp_monster = m_scene.instantiate()
				
				# 1. Extract Stats
				var m_hp = temp_monster.get("max_health")
				var m_dmg = temp_monster.get("damage")
				if m_hp != null and m_dmg != null:
					stat_text += "  (HP: " + _format_num(m_hp) + " | Dmg: " + _format_num(m_dmg) + ")"
				
				# 2. Extract Image (CRASH-PROOF & SPRITESHEET READY)
				var anim_sprite = temp_monster.get_node_or_null("AnimatedSprite2D")
				var basic_sprite = temp_monster.get_node_or_null("Sprite2D")
				
				# If the node is named AnimatedSprite2D but its type was changed to Sprite2D
				if anim_sprite != null and anim_sprite is Sprite2D:
					basic_sprite = anim_sprite
					anim_sprite = null
				
				# Safely extract from AnimatedSprite2D
				if anim_sprite and anim_sprite.get("sprite_frames") != null:
					m_icon = anim_sprite.sprite_frames.get_frame_texture(anim_sprite.animation, 0)
					m_color = anim_sprite.modulate
					
				# Safely extract from Sprite2D (Handles hframes/vframes for Swarms!)
				elif basic_sprite and basic_sprite.get("texture") != null:
					if basic_sprite.hframes > 1 or basic_sprite.vframes > 1:
						var atlas = AtlasTexture.new()
						atlas.atlas = basic_sprite.texture
						var frame_w = basic_sprite.texture.get_width() / basic_sprite.hframes
						var frame_h = basic_sprite.texture.get_height() / basic_sprite.vframes
						atlas.region = Rect2(0, 0, frame_w, frame_h)
						m_icon = atlas
					else:
						m_icon = basic_sprite.texture
					m_color = basic_sprite.modulate
					
				# Apply base color if the enemy script forces one
				if temp_monster.get("base_color") != null:
					m_color = temp_monster.base_color
				
				temp_monster.queue_free()
				
				_add_monster_stat_row(enemy_name, stat_text, m_icon, m_color)

# --- POPULATE ARMORY ---
func populate_armory():
	for child in armory_list.get_children():
		child.queue_free()
		
	for weapon_id in UpgradeDatabase.weapons_db:
		var w_data = UpgradeDatabase.weapons_db[weapon_id]
		
		var temp_weapon = w_data["scene"].instantiate()
		var w_damage = temp_weapon.base_damage
		var w_cooldown = temp_weapon.base_fire_rate
		var w_is_util = temp_weapon.is_utility
		temp_weapon.queue_free()
		
		var row = HBoxContainer.new()
		
		var icon = TextureRect.new()
		icon.texture = w_data["icon"]
		icon.custom_minimum_size = Vector2(32, 32)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(icon)
		
		var text_vbox = VBoxContainer.new()
		text_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(text_vbox)
		
		var name_lbl = Label.new()
		var stat_string = ""
		
		if w_is_util:
			stat_string = "  [Utility Aura]"
		else:
			# Applying the formatting function here as well!
			stat_string = "  (Dmg: " + _format_num(w_damage) + " | Cooldown: " + _format_num(w_cooldown) + "s)"
		
		name_lbl.text = w_data["name"] + " [" + w_data.get("rarity", "Common") + "]" + stat_string
		text_vbox.add_child(name_lbl)
		
		var desc_lbl = Label.new()
		var clean_desc = w_data["desc"].replace("[color=green]New Weapon[/color]\n", "")
		
		desc_lbl.text = clean_desc
		desc_lbl.modulate = Color(0.7, 0.7, 0.7)
		text_vbox.add_child(desc_lbl)
		
		armory_list.add_child(row)

# --- UI BUILDER HELPER FUNCTIONS ---
func add_stat_row(title: String, value: String):
	var row = HBoxContainer.new()
	
	var lbl_title = Label.new()
	lbl_title.text = title
	lbl_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(lbl_title)
	
	var lbl_val = Label.new()
	lbl_val.text = value
	lbl_val.modulate = Color("#fceda6")
	row.add_child(lbl_val)
	
	stats_list.add_child(row)

func _add_monster_stat_row(title: String, value: String, icon_texture: Texture2D = null, icon_color: Color = Color.WHITE):
	var row = HBoxContainer.new()
	
	if icon_texture:
		var icon_rect = TextureRect.new()
		icon_rect.texture = icon_texture
		icon_rect.modulate = icon_color
		icon_rect.custom_minimum_size = Vector2(64, 64)
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(icon_rect)
	
	var lbl_title = Label.new()
	lbl_title.text = title
	lbl_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(lbl_title)
	
	var lbl_val = Label.new()
	lbl_val.text = value
	lbl_val.modulate = Color("#fceda6") # Souls-like Gold
	row.add_child(lbl_val)
	
	stats_list.add_child(row)

# --- BUTTON SIGNALS ---
func _on_start_run_button_pressed():
	if currently_selected_char_node and currently_selected_char_node.is_unlocked:
		Global.total_runs_played += 1
		Global.save_game()
		Global.selected_character_scene = currently_selected_char_node.character_scene
		SceneChanger.change_scene("res://maps/map_1.tscn")

func _on_back_button_pressed():
	pass
