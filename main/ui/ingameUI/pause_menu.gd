extends CanvasLayer

# --- REFERENZEN (per Unique Name %) ---
@onready var content_control = %Control
@onready var stats_grid = %StatsGrid
@onready var weapons_grid = %WeaponsGrid

func _ready():
	visibility_changed.connect(_on_visibility_changed)
	
func _on_visibility_changed():
	if visible:
		content_control.visible = true 
		update_ui()

# --- HAUPTFUNKTION ---
func update_ui():
	var player = get_tree().get_first_node_in_group("player")
	
	if player:
		update_stats(player)
		update_weapons(player)

# --- TEIL A: STATS ---
func update_stats(player):
	for child in stats_grid.get_children():
		child.queue_free()

	# 1. HEALTH
	var current_hp = player.health_component.current_health
	var max_hp = player.health_component.max_health
	var hp_text = str(int(current_hp)) + " / " + str(int(max_hp))
	add_stat_row("❤ Max Health", hp_text)
	
	# 2. ARMOR
	var armor_color = Color.GREEN if player.armor > 0 else Color.WHITE
	add_stat_row("🛡 Armor", get_clean_text(player.armor), armor_color)
	
	# 3. RECOVERY
	var rec_text = get_clean_text(player.recovery) + "/sec"
	var rec_color = Color.GREEN if player.recovery > 0 else Color.WHITE
	add_stat_row("💖 Recovery", rec_text, rec_color)
	
	# 4. MIGHT (Schaden)
	var might_bonus = (player.might - 1.0) * 100
	var might_col = Color.GREEN if might_bonus > 0 else (Color.RED if might_bonus < 0 else Color.WHITE)
	add_stat_row("⚔ Might", get_clean_text(might_bonus) + "%", might_col)
	
	# 5. AREA
	var area_bonus = (player.area - 1.0) * 100
	var area_col = Color.GREEN if area_bonus > 0 else (Color.RED if area_bonus < 0 else Color.WHITE)
	add_stat_row("⭕ Area", get_clean_text(area_bonus) + "%", area_col)
	
	# 6. COOLDOWN (Negativ ist gut!)
	var cd_diff = (player.cooldown_mult - 1.0) * 100
	var cd_col = Color.GREEN if cd_diff < 0 else (Color.RED if cd_diff > 0 else Color.WHITE)
	add_stat_row("⏳ Cooldown", get_clean_text(cd_diff) + "%", cd_col)
	
	# 7. UTILITY: SPEED, LUCK & MAGNET
	add_stat_row("👟 Speed", str(int(player.speed)))
	
	var luck_bonus = (player.luck - 1.0) * 100
	var luck_col = Color.GREEN if luck_bonus > 0 else Color.WHITE
	add_stat_row("🍀 Luck", get_clean_text(luck_bonus) + "%", luck_col)
	
	var mag_bonus = (player.magnet_mult - 1.0) * 100
	var mag_col = Color.GREEN if mag_bonus > 0 else Color.WHITE
	add_stat_row("🧲 Magnet", get_clean_text(mag_bonus) + "%", mag_col)
	
	# 8. GROWTH
	var growth_bonus = (player.growth - 1.0) * 100
	var growth_col = Color.GREEN if growth_bonus > 0 else Color.WHITE
	add_stat_row("🌱 Growth", get_clean_text(growth_bonus) + "%", growth_col)
	
	# Kills für diesen Run (Rot)
	add_stat_row("💀 Run Kills", str(Global.run_total_kills), Color(1.0, 0.3, 0.3))
	
	# Kills über alle Runs hinweg (Gold)
	add_stat_row("👑 Total Kills", str(Global.lifetime_total_kills), Color(1.0, 0.8, 0.1))

# --- TEIL B: WAFFEN ---
func update_weapons(player):
	for child in weapons_grid.get_children():
		child.queue_free()
	
	var weapons_manager = player.get_node_or_null("WeaponInventory")
	
	if weapons_manager:
		var weapon_data_list = [] 
		
		for weapon in weapons_manager.get_children():
			if weapon.has_method("get_actual_damage"):
				# capitalize() macht aus "PhantomGlaive" -> "Phantom Glaive"
				var w_name = weapon.name.replace("Weapon", "").capitalize()
				var total_dmg = weapon.get("total_damage_dealt") 
				if total_dmg == null: total_dmg = 0.0
				
				# Wir holen uns alle wichtigen Werte von der Waffe
				var icon = weapon.get("weapon_icon")
				var is_util = weapon.get("is_utility")
				if is_util == null: is_util = false
				
				var lvl = weapon.get("level")
				if lvl == null: lvl = 1
				
				var max_lvl = weapon.get("max_level")
				if max_lvl == null: max_lvl = 5 # Standard-Max falls nicht definiert
				
				weapon_data_list.append({
					"name": w_name,
					"current": weapon.get_actual_damage(),
					"total": total_dmg,
					"icon": icon,
					"is_utility": is_util,
					"level": lvl,
					"max_level": max_lvl
				})
		
		# 1. NACH SCHADEN SORTIEREN (Die stärkste ist Index 0)
		weapon_data_list.sort_custom(func(a, b): return a["total"] > b["total"])
		
		var max_dmg_run = 0.0
		if weapon_data_list.size() > 0:
			max_dmg_run = weapon_data_list[0]["total"]
		
		# 2. ZEILEN ZEICHNEN
		for data in weapon_data_list:
			var info_color = Color(1.0, 0.4, 0.1) 
			var fill_ratio = 0.0 
			var level_display = ""
			
			# --- NEUES LEVEL-DESIGN (Rank Pips) ---
			if data["level"] >= data["max_level"]:
				# Goldenes, welliges MAX wenn fertig
				level_display = "[color=#ffaa00][wave amp=30 freq=3]MAX[/wave][/color]"
			else:
				# Erzeugt Pips: ◆◆◆◇◇
				for i in range(data["max_level"]):
					if i < data["level"]:
						level_display += "◆"
					else:
						level_display += "[color=#444444]◇[/color]"
			
			# Wir bauen den Namen mit den Pips in kleinerer Schrift dahinter
			var final_name_bb = "%s  [font_size=12]%s[/font_size]" % [data["name"], level_display]
			
			if data["is_utility"]:
				info_color = Color(0.2, 0.8, 1.0) 
				_add_sleek_weapon_row(final_name_bb, "Utility Aura", data["icon"], info_color, 0.0, true)
			else:
				var formatted_total = format_huge_number(data["total"])
				var w_info = "%s (%.1f Dmg)" % [formatted_total, data["current"]]
				
				if max_dmg_run > 0:
					fill_ratio = float(data["total"]) / float(max_dmg_run)
					
				_add_sleek_weapon_row(final_name_bb, w_info, data["icon"], info_color, fill_ratio, false)
			
		if weapon_data_list.size() == 0:
			show_empty_weapons_message()

# --- DIE VERBESSERTE ZEILE MIT RICHTEXT FÜR BBCODE ---
func _add_sleek_weapon_row(w_name_bb: String, w_info: String, icon_texture: Texture2D, info_color: Color, fill_ratio: float, is_util: bool):
	var row = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# 1. Das Mini-Icon
	var icon_rect = TextureRect.new()
	icon_rect.custom_minimum_size = Vector2(24, 24)
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if icon_texture:
		icon_rect.texture = icon_texture
	else:
		var fallback = PlaceholderTexture2D.new()
		fallback.size = Vector2(24, 24)
		icon_rect.texture = fallback
		icon_rect.modulate = Color(0.2, 0.1, 0.25) 
	row.add_child(icon_rect)
	
	# 2. Container für Text und Balken
	var right_vbox = VBoxContainer.new()
	right_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_vbox.add_theme_constant_override("separation", 0) 
	row.add_child(right_vbox)
	
	# 2a. Text-Zeile
	var text_hbox = HBoxContainer.new()
	right_vbox.add_child(text_hbox)
	
	# NAME ALS RICHTEXT (Wichtig für die farbigen Pips/MAX!)
	var lbl_name = RichTextLabel.new()
	lbl_name.bbcode_enabled = true
	lbl_name.text = w_name_bb
	lbl_name.fit_content = true
	lbl_name.autowrap_mode = TextServer.AUTOWRAP_OFF
	lbl_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_hbox.add_child(lbl_name)
	
	var lbl_info = Label.new()
	lbl_info.text = w_info
	lbl_info.custom_minimum_size.x = 150 
	lbl_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lbl_info.modulate = info_color
	text_hbox.add_child(lbl_info)
	
	# 2b. Der Fortschritts-Balken
	if not is_util: 
		var bar = ProgressBar.new()
		bar.custom_minimum_size.y = 4 
		bar.show_percentage = false 
		bar.max_value = 1.0
		bar.value = fill_ratio
		
		var sb_bg = StyleBoxFlat.new()
		sb_bg.bg_color = Color(0.05, 0.05, 0.05, 0.8) 
		bar.add_theme_stylebox_override("background", sb_bg)
		
		var sb_fill = StyleBoxFlat.new()
		sb_fill.bg_color = info_color 
		bar.add_theme_stylebox_override("fill", sb_fill)
		
		right_vbox.add_child(bar)
	
	weapons_grid.add_child(row)

# --- HILFSFUNKTIONEN ---

func get_clean_text(val: float) -> String:
	var rounded_val = snapped(val, 0.1)
	if is_equal_approx(fmod(rounded_val, 1.0), 0.0):
		return str(int(rounded_val))
	else:
		return "%.1f" % rounded_val

func add_stat_row(name_text: String, value_text: String, value_color: Color = Color.WHITE):
	var lbl_name = Label.new()
	lbl_name.text = name_text
	lbl_name.modulate = Color(0.8, 0.8, 0.8)
	stats_grid.add_child(lbl_name)
	
	var lbl_val = Label.new()
	lbl_val.text = value_text
	lbl_val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lbl_val.size_flags_horizontal = Control.SIZE_SHRINK_END
	lbl_val.modulate = value_color
	stats_grid.add_child(lbl_val)

func add_separator(target_grid):
	var spacer_left = Control.new()
	target_grid.add_child(spacer_left)
	var spacer_right = Control.new()
	spacer_right.custom_minimum_size.y = 16
	target_grid.add_child(spacer_right)

func add_weapon_entry(w_name, w_info):
	var row = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var lbl_n = Label.new()
	lbl_n.text = "⚔ " + w_name
	lbl_n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(lbl_n)
	
	var lbl_i = Label.new()
	lbl_i.text = w_info
	lbl_i.modulate = Color(1, 0.8, 0.2)
	row.add_child(lbl_i)
	
	weapons_grid.add_child(row)

func show_empty_weapons_message():
	var lbl = Label.new()
	lbl.text = "- No Weapons -"
	lbl.modulate = Color(0.5, 0.5, 0.5)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.custom_minimum_size.y = 40 
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	weapons_grid.add_child(lbl)

func format_huge_number(num: float) -> String:
	if num >= 1000000:
		return "%.1fM" % (num / 1000000.0)
	elif num >= 1000:
		return "%.1fk" % (num / 1000.0)    
	else:
		return str(int(num))              

# --- BUTTON SIGNALE ---

func _on_resume_button_pressed():
	var manager = get_tree().get_first_node_in_group("Managers")
	if not manager:
		print("FEHLER: GameManager nicht gefunden! Pfad im Script prüfen.")
	if manager:
		manager.change_state(manager.GameState.PLAYING)

func _on_quit_button_pressed():
	get_tree().quit()
