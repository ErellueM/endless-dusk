extends Control

@onready var gold_label = $TopBar/GoldBox/GoldLabel
@onready var char_grid = $TabContainer/Characters/GridContainer
@onready var selected_info_label = $TabContainer/Characters/SelectedCharInfo
@onready var start_button = $StartRunButton

@onready var stats_list = $TabContainer/Stats/ScrollContainer/MarginContainer/VBoxContainer
@onready var armory_list = $TabContainer/Armory/ScrollContainer/VBoxContainer

var currently_selected_char_node = null

func _ready():
	update_gold_display()
	
	var start_card = null
	for char_card in char_grid.get_children():
		char_card.setup()
		char_card.character_clicked.connect(_on_character_card_clicked)
		if char_card.character_name == "Soilder":
			start_card = char_card
	if start_card:
		_on_character_card_clicked(start_card)
			
	populate_stats()
	populate_armory()

func update_gold_display():
	gold_label.text = str(Global.gold)

func _on_character_card_clicked(clicked_card):
	# Farbe des Info-Labels immer erst mal auf Standard (Weiß) zurücksetzen
	selected_info_label.modulate = Color.WHITE 
	
	if clicked_card.is_unlocked:
		currently_selected_char_node = clicked_card
		selected_info_label.text = "Selected: " + clicked_card.character_name
		start_button.disabled = false
		start_button.text = "START RUN"
		
		# Visuelles Highlight
		for card in char_grid.get_children():
			if card.is_unlocked:
				var name_label = card.get_node("InfoContainer/NameLabel")
				if card == clicked_card:
					card.modulate = Color(1.0, 1.0, 1.0, 1.0) 
					if name_label: name_label.modulate = Color("#fceda6") 
				else:
					card.modulate = Color(0.4, 0.4, 0.4, 1.0) 
					if name_label: name_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		if Global.gold >= clicked_card.unlock_cost:
			# Man kann es sich leisten!
			selected_info_label.text = "Buy " + clicked_card.character_name + " for " + str(clicked_card.unlock_cost) + "G?"
			start_button.disabled = true
			start_button.text = "LOCKED"
		else:
			# ZU WENIG GOLD!
			selected_info_label.text = "NOT ENOUGH GOLD (" + str(clicked_card.unlock_cost) + "G)"
			selected_info_label.modulate = Color(1.0, 0.2, 0.2) # Text wird Rot!
			start_button.disabled = true
			start_button.text = "LOCKED"
			
			# Kleiner "Wackel"-Effekt für sauberes Game Feel
			var tween = create_tween()
			var start_x = selected_info_label.position.x
			tween.tween_property(selected_info_label, "position:x", start_x + 5, 0.05)
			tween.tween_property(selected_info_label, "position:x", start_x - 5, 0.05)
			tween.tween_property(selected_info_label, "position:x", start_x, 0.05)

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
	add_stat_row("Highest Level Reached:", "Level " + str(Global.highest_level_reached))
	add_stat_row("Total Kills:", _format_big_number(Global.lifetime_total_kills))
	add_stat_row("Highest Survival Time:", _format_time(Global.highest_survival_time))
	add_stat_row("Total Playtime:", _format_time(Global.total_time_played))
	add_stat_row("Total Damage Dealt:", _format_big_number(Global.lifetime_damage_dealt))
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
		# Now we get ALL enemies from the DB that belong to this category, regardless of kills!
		var enemies_in_this_cat = []
		for enemy_name in Global.monsters_db:
			if Global.monsters_db[enemy_name]["category"] == cat:
				enemies_in_this_cat.append(enemy_name)
				
		if enemies_in_this_cat.size() > 0:
			var title = Label.new()
			title.text = "\n" + category_titles[cat]
			title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			title.modulate = Color(0.6, 0.6, 0.6)
			stats_list.add_child(title)
			
			for enemy_name in enemies_in_this_cat:
				# Use .get() to return 0 safely if the enemy hasn't been killed yet
				var amount = Global.lifetime_kills_by_type.get(enemy_name, 0)
				var is_discovered = amount > 0
				
				# Set Display Name
				var display_name = enemy_name if is_discovered else "???"
				var stat_text = str(amount) + " Killed"
				
				var m_icon = null
				var m_color = Color.WHITE
				
				var m_scene = Global.monsters_db[enemy_name]["scene"]
				var temp_monster = m_scene.instantiate()
				
				# Extract Image 
				var anim_sprite = temp_monster.get_node_or_null("AnimatedSprite2D")
				var basic_sprite = temp_monster.get_node_or_null("Sprite2D")
				
				if anim_sprite != null and anim_sprite is Sprite2D:
					basic_sprite = anim_sprite
					anim_sprite = null
				
				if anim_sprite and anim_sprite.get("sprite_frames") != null:
					m_icon = anim_sprite.sprite_frames.get_frame_texture(anim_sprite.animation, 0)
					if is_discovered: m_color = anim_sprite.modulate
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
					if is_discovered: m_color = basic_sprite.modulate
				
				# Setup Stats and Colors based on Discovery
				if is_discovered:
					if temp_monster.get("base_color") != null:
						m_color = temp_monster.base_color
						
					var m_hp = temp_monster.get("max_health")
					var m_dmg = temp_monster.get("damage")
					if m_hp != null and m_dmg != null:
						stat_text += "  (HP: " + _format_num(m_hp) + " | Dmg: " + _format_num(m_dmg) + ")"
				else:
					# SILHOUETTE EFFECT: Override color to very dark gray/black
					m_color = Color(0.0, 0.0, 0.0, 0.5)
					stat_text += "  (Stats Unknown)"
				
				temp_monster.queue_free()
				
				# Pass is_discovered to the row builder to dim the text
				_add_monster_stat_row(display_name, stat_text, m_icon, m_color, is_discovered)

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

# Notice the new 'is_discovered' parameter here!
func _add_monster_stat_row(title: String, value: String, icon_texture: Texture2D = null, icon_color: Color = Color.WHITE, is_discovered: bool = true):
	var row = HBoxContainer.new()
	
	if icon_texture:
		var icon_rect = TextureRect.new()
		icon_rect.texture = icon_texture
		icon_rect.modulate = icon_color
		
		# --- ALIGNMENT FIX ---
		# Force a 64x64 box so the text is always perfectly aligned in a straight column
		icon_rect.custom_minimum_size = Vector2(32, 32)
		# KEEP_CENTERED means: Do NOT stretch the image! Just put the original image in the middle of the 64x64 box.
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		
		row.add_child(icon_rect)
	
	var lbl_title = Label.new()
	lbl_title.text = title
	lbl_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Dim the enemy name if undiscovered
	if not is_discovered:
		lbl_title.modulate = Color(0.5, 0.5, 0.5) 
		
	row.add_child(lbl_title)
	
	var lbl_val = Label.new()
	lbl_val.text = value
	
	# Use gold if discovered, dull gray if undiscovered
	lbl_val.modulate = Color("#fceda6") if is_discovered else Color(0.4, 0.4, 0.4)
	
	row.add_child(lbl_val)
	stats_list.add_child(row)

func _format_time(total_seconds: float) -> String:
	var t = int(total_seconds)
	var days = t / 86400
	var hours = (t / 3600) % 24
	var minutes = (t / 60) % 60
	var seconds = t % 60
	
	var result = ""
	if days > 0:
		result += str(days) + "d "
	if hours > 0 or days > 0:
		result += str(hours) + "h "
	if minutes > 0 or hours > 0 or days > 0:
		result += str(minutes) + "m "
	result += str(seconds) + "s"
	return result.strip_edges()

# --- HELPER: FORMAT BIG NUMBERS (Scales to Infinity) ---
func _format_big_number(val: float) -> String:
	var suffixes = ["", "K", "M", "B", "T", "Qa", "Qi"]
	var suffix_index = 0
	var display_val = val
	
	while display_val >= 1000.0 and suffix_index < suffixes.size() - 1:
		display_val /= 1000.0
		suffix_index += 1
		
	if suffix_index == 0:
		return str(int(display_val))
	else:
		return "%.2f%s" % [display_val, suffixes[suffix_index]]

# --- BUTTON SIGNALS ---
func _on_start_run_button_pressed():
	if currently_selected_char_node and currently_selected_char_node.is_unlocked:
		Global.total_runs_played += 1
		Global.save_game()
		Global.selected_character_scene = currently_selected_char_node.character_scene
		SceneChanger.change_scene("res://maps/map_1.tscn")

func _on_back_button_pressed():
	pass
