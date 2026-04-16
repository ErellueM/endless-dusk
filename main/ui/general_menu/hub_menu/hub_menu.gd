extends Control

@onready var gold_label = $TopBar/GoldBox/GoldLabel
@onready var char_grid = $TabContainer/Characters/GridContainer
@onready var selected_info_label = $TabContainer/Characters/SelectedCharInfo
@onready var start_button = $StartRunButton

@onready var stats_list = $TabContainer/Stats/ScrollContainer/MarginContainer/VBoxContainer
@onready var armory_list = $TabContainer/Armory/ScrollContainer/VBoxContainer
@onready var relics_list = $TabContainer/Relics/ScrollContainer/MarginContainer/VBoxContainer

var rarity_colors = {
	"Common": Color("#9d9d9d"),
	"Uncommon": Color("#7fb06d"),
	"Rare": Color("#5c9be6"),
	"Epic": Color("#c95b8d"),
	"Legendary": Color("#ff9933")
}
var rarity_values = {
	"Legendary": 5,
	"Epic": 4,
	"Rare": 3,
	"Uncommon": 2,
	"Common": 1
}
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
	populate_relics()

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
	add_stat_row("Total Kills:", _format_number_dotted(Global.lifetime_total_kills))
	add_stat_row("Highest Survival Time:", _format_time(Global.highest_survival_time))
	add_stat_row("Total Playtime:", _format_time(Global.total_time_played))
	add_stat_row("Total Damage Dealt:", _format_number_dotted(Global.lifetime_damage_dealt))
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
		
	# 1. Wir holen uns alle IDs und sortieren sie mit unserer brandneuen Logik!
	var sorted_weapon_ids = UpgradeDatabase.weapons_db.keys()
	sorted_weapon_ids.sort_custom(_sort_weapons)
		
	# 2. Wir iterieren über die SORTIERTE Liste
	for weapon_id in sorted_weapon_ids:
		var w_data = UpgradeDatabase.weapons_db[weapon_id]
		var is_discovered = weapon_id in Global.discovered_weapons
		
		# Wenn unentdeckt, ist alles dunkel. Wenn entdeckt, nutzen wir die Rarity-Farbe.
		var rarity = w_data.get("rarity", "Common")
		var r_color = rarity_colors.get(rarity, Color.WHITE) if is_discovered else Color(0.4, 0.4, 0.4)
		
		var row = HBoxContainer.new()
		
		# --- DAS ICON ---
		var icon = TextureRect.new()
		icon.texture = w_data["icon"]
		icon.custom_minimum_size = Vector2(48, 48)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		if not is_discovered:
			# Schwarze Silhouette für unentdeckte Waffen
			icon.modulate = Color(0.0, 0.0, 0.0, 0.5) 
		
		row.add_child(icon)
		
		# --- DER TEXT-BEREICH ---
		var text_vbox = VBoxContainer.new()
		text_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text_vbox.add_theme_constant_override("separation", 2) 
		row.add_child(text_vbox)
		
		var name_lbl = Label.new()
		
		if is_discovered:
			# WAFFE IST BEKANNT: Zeige volle Stats!
			var temp_weapon = w_data["scene"].instantiate()
			var w_damage = temp_weapon.base_damage
			var w_cooldown = temp_weapon.base_fire_rate
			var w_is_util = temp_weapon.is_utility
			temp_weapon.queue_free()
			
			var stat_string = "  [Utility Aura]" if w_is_util else "  (Dmg: " + _format_num(w_damage) + " | Cooldown: " + _format_num(w_cooldown) + "s)"
			name_lbl.text = w_data["name"] + " [" + rarity + "]" + stat_string
			
			# Farbe und Schatten für den Titel
			name_lbl.add_theme_color_override("font_color", r_color)
			name_lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
			name_lbl.add_theme_constant_override("shadow_offset_y", 1)
			
			var desc_lbl = Label.new()
			var clean_desc = w_data["desc"].replace("[color=green]New Weapon[/color]\n", "")
			desc_lbl.text = clean_desc
			desc_lbl.modulate = Color(0.6, 0.6, 0.6) 
			text_vbox.add_child(name_lbl)
			text_vbox.add_child(desc_lbl)
			
		else:
			# WAFFE IST UNBEKANNT: Nur "???" anzeigen
			name_lbl.text = "??? [Unknown Weapon]"
			name_lbl.add_theme_color_override("font_color", r_color) # Das ist unser dunkles Grau von oben
			text_vbox.add_child(name_lbl)
			
			var desc_lbl = Label.new()
			desc_lbl.text = "Find this weapon during a run to unlock its details."
			desc_lbl.modulate = Color(0.3, 0.3, 0.3) # Sehr schwaches Grau
			text_vbox.add_child(desc_lbl)
		
		armory_list.add_child(row)

# --- HELPER: CUSTOM SORTING FOR RELICS ---
func _sort_relics(a: Dictionary, b: Dictionary) -> bool:
	var is_a_unlocked = a["name"] in Global.discovered_upgrades
	var is_b_unlocked = b["name"] in Global.discovered_upgrades
	
	if is_a_unlocked and not is_b_unlocked: return true
	if not is_a_unlocked and is_b_unlocked: return false
	
	var val_a = rarity_values.get(a.get("rarity", "Common"), 1)
	var val_b = rarity_values.get(b.get("rarity", "Common"), 1)
	
	if val_a != val_b:
		return val_a > val_b 
		
	return a["name"] < b["name"]


# --- POPULATE RELICS (PASSIVES) ---
func populate_relics():
	for child in relics_list.get_children():
		child.queue_free()
		
	# 1. Hole alle Stat-Upgrades und sortiere sie
	var sorted_upgrades = UpgradeDatabase.stat_upgrades.duplicate()
	sorted_upgrades.sort_custom(_sort_relics)
		
	# 2. Iteriere über die sortierte Liste
	for u_data in sorted_upgrades:
		var u_name = u_data["name"]
		var is_discovered = u_name in Global.discovered_upgrades
		
		var rarity = u_data.get("rarity", "Common")
		var r_color = rarity_colors.get(rarity, Color.WHITE) if is_discovered else Color(0.4, 0.4, 0.4)
		
		var row = HBoxContainer.new()
		
		# --- ICON ZUWEISEN ---
		var icon = TextureRect.new()
		# Finde das richtige Icon basierend auf dem ersten Stat-Key
		if u_data.has("stats") and u_data["stats"].size() > 0:
			var primary_stat_key = u_data["stats"][0]["key"]
			icon.texture = UpgradeDatabase.stat_icons.get(primary_stat_key)
			
		icon.custom_minimum_size = Vector2(48, 48)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		if not is_discovered:
			icon.modulate = Color(0.0, 0.0, 0.0, 0.5) 
		
		row.add_child(icon)
		
		# --- TEXT BEREICH ---
		var text_vbox = VBoxContainer.new()
		text_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text_vbox.add_theme_constant_override("separation", 2) 
		row.add_child(text_vbox)
		
		var name_lbl = Label.new()
		
		if is_discovered:
			name_lbl.text = u_name + " [" + rarity + "]"
			name_lbl.add_theme_color_override("font_color", r_color)
			name_lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
			name_lbl.add_theme_constant_override("shadow_offset_y", 1)
			
			var desc_lbl = Label.new()
			var clean_desc = u_data["desc"].replace("[color=green]", "").replace("[/color]", "").replace("[color=red]", "")
			desc_lbl.text = clean_desc
			desc_lbl.modulate = Color(0.6, 0.6, 0.6) 
			
			text_vbox.add_child(name_lbl)
			text_vbox.add_child(desc_lbl)
		else:
			name_lbl.text = "??? [Unknown Relic]"
			name_lbl.add_theme_color_override("font_color", r_color) 
			text_vbox.add_child(name_lbl)
			
			var desc_lbl = Label.new()
			desc_lbl.text = "Unlock this passive by finding it during a run."
			desc_lbl.modulate = Color(0.3, 0.3, 0.3)
			text_vbox.add_child(desc_lbl)
		
		relics_list.add_child(row)

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

func _format_number_dotted(val: float) -> String:
	var str_val = str(int(val))
	var result = ""
	var count = 0
	
	# Wir gehen die Ziffernfolge von hinten nach vorne durch
	for i in range(str_val.length() - 1, -1, -1):
		if count == 3:
			result = "." + result # Für US-Schreibweise hier einfach ein "," eintragen
			count = 0
		result = str_val[i] + result
		count += 1
		
	return result
	
func _sort_weapons(a: String, b: String) -> bool:
	var is_a_unlocked = a in Global.discovered_weapons
	var is_b_unlocked = b in Global.discovered_weapons
	
	# Regel 1: Entdeckte Items kommen VOR unentdeckten
	if is_a_unlocked and not is_b_unlocked: return true
	if not is_a_unlocked and is_b_unlocked: return false
	
	var data_a = UpgradeDatabase.weapons_db[a]
	var data_b = UpgradeDatabase.weapons_db[b]
	
	# Regel 2: Wenn beide den gleichen Status haben, sortiere nach Seltenheit (Legendary zuerst!)
	var val_a = rarity_values.get(data_a.get("rarity", "Common"), 1)
	var val_b = rarity_values.get(data_b.get("rarity", "Common"), 1)
	
	if val_a != val_b:
		return val_a > val_b 
		
	# Regel 3: Wenn Status UND Seltenheit gleich sind, sortiere Alphabetisch (A-Z)
	return data_a["name"] < data_b["name"]
	
# --- BUTTON SIGNALS ---
func _on_start_run_button_pressed():
	if currently_selected_char_node and currently_selected_char_node.is_unlocked:
		Global.total_runs_played += 1
		Global.save_game()
		Global.selected_character_scene = currently_selected_char_node.character_scene
		SceneChanger.change_scene("res://maps/map_1.tscn")

func _on_back_button_pressed():
	pass
