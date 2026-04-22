extends CanvasLayer

@onready var anim_player = $AnimationPlayer
@onready var you_died_label = $YouDied
@onready var ui_container = $UI_Container

# Buttons Hauptbildschirm
@onready var view_stats_button = $UI_Container/ButtonContainer/ViewStatsButton
@onready var restart_button = $UI_Container/ButtonContainer/RestartButton
@onready var quit_button = $UI_Container/ButtonContainer/QuitButton

# Unlocks Hauptbildschirm
@onready var unlocks_container = $UI_Container/UnlocksContainer
@onready var unlocks_list = $UI_Container/UnlocksContainer/UnlocksList

# Tooltip
@onready var custom_tooltip = $CustomTooltip
@onready var tooltip_text = $CustomTooltip/MarginContainer/TooltipText

# Stats Panel (Versteckt)
@onready var stats_panel = $StatsPanel
@onready var stats_grid = $StatsPanel/MarginContainer/VBoxContainer/StatsSplitter/ScrollContainer/MarginContainer/StatsGrid
@onready var weapons_grid = $StatsPanel/MarginContainer/VBoxContainer/StatsSplitter/WeaponsGrid
@onready var close_stats_button = $StatsPanel/MarginContainer/VBoxContainer/CloseStatsButton

func _ready():
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	view_stats_button.pressed.connect(_on_view_stats_pressed)
	close_stats_button.pressed.connect(_on_close_stats_pressed)
	custom_tooltip.hide()
	stats_panel.hide()

func show_game_over():
	var final_level = 1
	var raw_time = 0.0

	var player = get_tree().get_first_node_in_group("player")
	if player: final_level = player.level

	var game_ui = get_tree().get_first_node_in_group("GameUI")
	if game_ui and "time_elapsed" in game_ui:
		raw_time = game_ui.time_elapsed
	
	# --- BUGFIX: STATS RETTEN ---
	var saved_kills = Global.run_total_kills
	var saved_damage = Global.run_damage_dealt
	
	# Beendet den Run und löscht temporäre Stats (achievements_this_run bleibt aber erhalten bis zum nächsten Start!)
	Global.end_run(raw_time, final_level)

	# UI zurücksetzen
	custom_tooltip.hide()
	stats_panel.hide()
	you_died_label.show()
	ui_container.show()

	# Füllt das UI
	_populate_unlocks()
	if player:
		_populate_run_stats(player, final_level, raw_time, saved_kills, saved_damage)
		_populate_weapons(player)

	show()
	anim_player.play("fade_in")

func _process(delta):
	if custom_tooltip.visible:
		var mouse_pos = custom_tooltip.get_global_mouse_position()
		var target_pos = mouse_pos #+ Vector2(15, 15)
		
		# Hole die aktuelle Bildschirmgroesse und Tooltipgroesse
		var screen_size = get_viewport().get_visible_rect().size
		var tooltip_size = custom_tooltip.size
		
		# Wenn der Tooltip rechts aus dem Bild ragt, zeige ihn links von der Maus
		if target_pos.x + tooltip_size.x > screen_size.x:
			target_pos.x = mouse_pos.x - tooltip_size.x - 5
			
		# Wenn der Tooltip unten aus dem Bild ragt, zeige ihn ueber der Maus
		if target_pos.y + tooltip_size.y > screen_size.y:
			target_pos.y = mouse_pos.y - tooltip_size.y - 5
			
		custom_tooltip.global_position = target_pos

# --- UI TOGGLES ---

func _on_view_stats_pressed():
	you_died_label.hide()
	ui_container.hide()
	custom_tooltip.hide()
	stats_panel.show()

func _on_close_stats_pressed():
	stats_panel.hide()
	you_died_label.show()
	ui_container.show()

# --- UNLOCKS & TOOLTIP ---

func _populate_unlocks():
	print("Achievements this run: ", Global.achievements_this_run) # DEBUG PRINT
	
	if Global.achievements_this_run.size() == 0:
		unlocks_container.hide()
		return
		
	unlocks_container.show()
	for child in unlocks_list.get_children():
		child.queue_free()
		
	for ach_id in Global.achievements_this_run:
		if not AchievementDatabase.achievements.has(ach_id): continue
		var data = AchievementDatabase.achievements[ach_id]
		
		# Verwende einen Button anstelle eines PanelContainers für zuverlässige Klick/Hover-Events
		var icon_btn = Button.new()
		icon_btn.custom_minimum_size = Vector2(48, 48)
		icon_btn.flat = true # Kein Standard-Button-Hintergrund
		
		var style_box = StyleBoxFlat.new()
		style_box.bg_color = Color(0.0, 0.0, 0.0, 1.0)
		style_box.border_width_left = 2
		style_box.border_width_top = 2
		style_box.border_width_right = 2
		style_box.border_width_bottom = 2
		style_box.border_color = Color("#fceda6") 
		icon_btn.add_theme_stylebox_override("normal", style_box)
		icon_btn.add_theme_stylebox_override("hover", style_box) # Verhindert Flackern
		icon_btn.add_theme_stylebox_override("pressed", style_box)
		
		var icon = TextureRect.new()
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 4) # Margins
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE # WICHTIG: Das Bild soll die Maus ignorieren, der Button fängt es ab
		
		match data["type"]:
			"time": icon.texture = preload("res://assets/art/destructables/barrel/item_drops/coin.png")
			"kills": icon.texture = preload("res://assets/art/destructables/barrel/item_drops/coin.png")
			_: icon.texture = preload("res://assets/art/destructables/barrel/item_drops/coin.png")
			
		icon_btn.add_child(icon)
		unlocks_list.add_child(icon_btn)
		
		# Verbinde die Signale mit dem Button
		icon_btn.mouse_entered.connect(_on_icon_mouse_entered.bind(ach_id))
		icon_btn.mouse_exited.connect(_on_icon_mouse_exited)


func _on_icon_mouse_entered(ach_id: String):
	tooltip_text.text = _build_tooltip_text(ach_id)
	custom_tooltip.show()
	custom_tooltip.move_to_front() # Stellt sicher, dass es ganz oben gerendert wird

func _on_icon_mouse_exited():
	custom_tooltip.hide()

func _build_tooltip_text(ach_id: String) -> String:
	var ach_data = AchievementDatabase.achievements[ach_id]
	
	# Block 1: Achievement Info (Schriftgroesse 20 und 16)
	var text = "[color=#fceda6][b][font_size=20]" + ach_data["name"] + "[/font_size][/b][/color]\n"
	text += "[color=#cccccc][font_size=16]" + ach_data["desc"] + "[/font_size][/color]\n\n"
	
	var found_items = false
	text += "[color=#7fb06d][b][font_size=18]Unlocked Items:[/font_size][/b][/color]\n"
	
	# Block 2: Waffen durchsuchen
	for w_id in UpgradeDatabase.weapons_db:
		var w_data = UpgradeDatabase.weapons_db[w_id]
		if w_data.has("unlock_req") and w_data["unlock_req"] == ach_id:
			found_items = true
			var rarity_color = _get_rarity_color_hex(w_data.get("rarity", "Common"))
			text += "• [color=" + rarity_color + "][font_size=16]" + w_data["name"] + "[/font_size][/color]\n"
			var clean_desc = w_data["desc"].replace("[color=green]New Weapon[/color]\n", "")
			text += "  [color=#aaaaaa][font_size=16]" + clean_desc + "[/font_size][/color]\n"
			
	# Block 3: Relics durchsuchen
	for u_data in UpgradeDatabase.stat_upgrades:
		if u_data.has("unlock_req") and u_data["unlock_req"] == ach_id:
			found_items = true
			var rarity_color = _get_rarity_color_hex(u_data.get("rarity", "Common"))
			text += "• [color=" + rarity_color + "][font_size=16]" + u_data["name"] + "[/font_size][/color]\n"
			var clean_desc = u_data["desc"].replace("[color=green]", "").replace("[/color]", "").replace("[color=red]", "")
			text += "  [color=#aaaaaa][font_size=16]" + clean_desc + "[/font_size][/color]\n"
			
	if not found_items:
		text += "[color=#aaaaaa][font_size=16]No specific items unlocked.[/font_size][/color]"
		
	return text

func _get_rarity_color_hex(rarity: String) -> String:
	match rarity:
		"Common": return "#9d9d9d"
		"Uncommon": return "#7fb06d"
		"Rare": return "#5c9be6"
		"Epic": return "#c95b8d"
		"Legendary": return "#ff9933"
		_: return "#ffffff"

# --- DETAILED STATS (STATS PANEL) ---

func _populate_run_stats(player, final_level, raw_time, final_kills, final_damage):
	for child in stats_grid.get_children():
		child.queue_free()
		
	var time_str = _format_time(raw_time)
	var time_icon = preload("res://assets/art/icons/stats_icon/movement_speed_wingboots.png")
	var kill_icon = preload("res://assets/art/icons/stats_icon/might_gauntlet.png")
	
	add_stat_row("Level Reached", str(final_level), UpgradeDatabase.stat_icons.get("growth"))
	add_stat_row("Survival Time", time_str, time_icon)
	add_stat_row("Enemies Killed", str(final_kills), kill_icon, Color(1.0, 0.3, 0.3))
	add_stat_row("Total Damage", format_huge_number(final_damage), null, Color.ORANGE)
	
	var current_hp = player.health_component.current_health
	var max_hp = player.health_component.max_health
	var hp_text = str(int(current_hp)) + " / " + str(int(max_hp))
	add_stat_row("Max Health", hp_text, UpgradeDatabase.stat_icons["max_health"])

	var armor_col = Color.GREEN if player.armor > 0 else (Color.RED if player.armor < 0 else Color.WHITE)
	add_stat_row("Armor", get_clean_text(player.armor), UpgradeDatabase.stat_icons["armor"], armor_col)

	var rec_text = get_clean_text(player.recovery) + "/sec"
	var rec_color = Color.GREEN if player.recovery > 0 else (Color.RED if player.recovery < 0 else Color.WHITE)
	add_stat_row("Recovery", rec_text, UpgradeDatabase.stat_icons["recovery"], rec_color)

	var might_bonus = (player.might - 1.0) * 100
	var might_col = Color.GREEN if might_bonus > 0 else (Color.RED if might_bonus < 0 else Color.WHITE)
	add_stat_row("Might", get_clean_text(might_bonus) + "%", UpgradeDatabase.stat_icons["might"], might_col)

	var area_bonus = (player.area - 1.0) * 100
	var area_col = Color.GREEN if area_bonus > 0 else (Color.RED if area_bonus < 0 else Color.WHITE)
	add_stat_row("Area", get_clean_text(area_bonus) + "%", UpgradeDatabase.stat_icons["area"], area_col)

	var as_bonus = player.attack_speed_bonus * 100
	var as_col = Color.GREEN if as_bonus > 0 else (Color.RED if as_bonus < 0 else Color.WHITE)
	add_stat_row("Attack Speed", get_clean_text(as_bonus) + "%", UpgradeDatabase.stat_icons["attack_speed_bonus"], as_col)

	add_stat_row("Speed", str(int(player.speed)), UpgradeDatabase.stat_icons["speed"])

	var luck_bonus = (player.luck - 1.0) * 100
	var luck_col = Color.GREEN if luck_bonus > 0 else (Color.RED if luck_bonus < 0 else Color.WHITE)
	add_stat_row("Luck", get_clean_text(luck_bonus) + "%", UpgradeDatabase.stat_icons["luck"], luck_col)

	var mag_bonus = (player.magnet_mult - 1.0) * 100
	var mag_col = Color.GREEN if mag_bonus > 0 else (Color.RED if mag_bonus < 0 else Color.WHITE)
	add_stat_row("Magnet", get_clean_text(mag_bonus) + "%", UpgradeDatabase.stat_icons["magnet_mult"], mag_col)

	var growth_bonus = (player.growth - 1.0) * 100
	var growth_col = Color.GREEN if growth_bonus > 0 else (Color.RED if growth_bonus < 0 else Color.WHITE)
	add_stat_row("Growth", get_clean_text(growth_bonus) + "%", UpgradeDatabase.stat_icons["growth"], growth_col)

func _populate_weapons(player):
	for child in weapons_grid.get_children():
		child.queue_free()

	var weapons_manager = player.get_node_or_null("WeaponInventory")
	if not weapons_manager: return

	var weapon_data_list = []
	for weapon in weapons_manager.get_children():
		if weapon.has_method("get_actual_damage"):
			var total_dmg = weapon.get("total_damage_dealt")
			if total_dmg == null: total_dmg = 0.0
			
			var w_level = weapon.get("level")
			var w_max_level = weapon.get("max_level")
			
			weapon_data_list.append({
				"name": weapon.name.replace("Weapon", "").capitalize(),
				"current": weapon.get_actual_damage(),
				"total": total_dmg,
				"icon": weapon.get("weapon_icon"),
				"is_utility": weapon.get("is_utility") == true,
				"level": w_level if w_level != null else 1,
				"max_level": w_max_level if w_max_level != null else 5
			})

	weapon_data_list.sort_custom(func(a, b): return a["total"] > b["total"])
	var max_dmg_run = weapon_data_list[0]["total"] if weapon_data_list.size() > 0 else 0.0

	for data in weapon_data_list:
		var info_color = Color(0.2, 0.8, 1.0) if data["is_utility"] else Color(1.0, 0.4, 0.1)
		var fill_ratio = float(data["total"]) / float(max_dmg_run) if max_dmg_run > 0 else 0.0
		
		var level_display = "[font_size=16][color=#ff2222]MAX[/color]" if data["level"] >= data["max_level"] else ""
		if data["level"] < data["max_level"]:
			for i in range(data["max_level"]):
				level_display += "◆" if i < data["level"] else "[color=#444444]◇[/color]"

		var final_name_bb = "%s  [font_size=12]%s[/font_size]" % [data["name"], level_display]
		var w_info = "Utility" if data["is_utility"] else "%s Dmg" % [format_huge_number(data["total"])]
		
		_add_sleek_weapon_row(final_name_bb, w_info, data["icon"], info_color, fill_ratio, data["is_utility"])

func add_stat_row(name_text: String, value_text: String, icon_texture: Texture2D = null, value_color: Color = Color.WHITE):
	var left_hbox = HBoxContainer.new()
	left_hbox.add_theme_constant_override("separation", 8)
	if icon_texture:
		var icon_rect = TextureRect.new()
		icon_rect.texture = icon_texture
		icon_rect.custom_minimum_size = Vector2(24, 24)
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		left_hbox.add_child(icon_rect)
		
	var lbl_name = Label.new()
	lbl_name.text = name_text
	lbl_name.modulate = Color(0.8, 0.8, 0.8)
	left_hbox.add_child(lbl_name)
	stats_grid.add_child(left_hbox)

	var lbl_val = Label.new()
	lbl_val.text = value_text
	lbl_val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lbl_val.size_flags_horizontal = Control.SIZE_SHRINK_END
	lbl_val.modulate = value_color
	stats_grid.add_child(lbl_val)

func _add_sleek_weapon_row(w_name_bb: String, w_info: String, icon_texture: Texture2D, info_color: Color, fill_ratio: float, is_util: bool):
	var row = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 8)

	var icon_panel = PanelContainer.new()
	icon_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.0, 0.0, 0.0, 1.0)
	style_box.border_width_left = 1
	style_box.border_width_top = 1
	style_box.border_width_right = 1
	style_box.border_width_bottom = 1
	style_box.content_margin_left = 1
	style_box.content_margin_top = 1
	style_box.content_margin_right = 1
	style_box.content_margin_bottom = 2
	style_box.border_color = Color("440000") 
	style_box.anti_aliasing = false
	icon_panel.add_theme_stylebox_override("panel", style_box)

	var icon_rect = TextureRect.new()
	icon_rect.custom_minimum_size = Vector2(24, 24)
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.texture = icon_texture if icon_texture else PlaceholderTexture2D.new()
	icon_panel.add_child(icon_rect)
	row.add_child(icon_panel)

	var right_vbox = VBoxContainer.new()
	right_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_vbox.add_theme_constant_override("separation", 0)
	row.add_child(right_vbox)

	var text_hbox = HBoxContainer.new()
	right_vbox.add_child(text_hbox)

	var lbl_name = RichTextLabel.new()
	lbl_name.bbcode_enabled = true
	lbl_name.text = w_name_bb
	lbl_name.fit_content = true
	lbl_name.autowrap_mode = TextServer.AUTOWRAP_OFF
	lbl_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_hbox.add_child(lbl_name)

	var lbl_info = Label.new()
	lbl_info.text = w_info
	lbl_info.custom_minimum_size.x = 100
	lbl_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lbl_info.modulate = info_color
	text_hbox.add_child(lbl_info)

	if not is_util:
		var bar = ProgressBar.new()
		bar.custom_minimum_size.y = 4
		bar.show_percentage = false
		bar.max_value = 1.0
		bar.value = fill_ratio
		var sb_fill = StyleBoxFlat.new()
		sb_fill.bg_color = info_color
		bar.add_theme_stylebox_override("fill", sb_fill)
		right_vbox.add_child(bar)

	weapons_grid.add_child(row)

func format_huge_number(num: float) -> String:
	if num >= 1000000000000.0: return "%.1fT" % (num / 1000000000000.0)
	elif num >= 1000000000.0: return "%.1fB" % (num / 1000000000.0)
	elif num >= 1000000.0: return "%.1fM" % (num / 1000000.0)
	elif num >= 1000.0: return "%.1fk" % (num / 1000.0)
	else: return str(int(num))

func _format_time(total_seconds: float) -> String:
	var t = int(total_seconds)
	var minutes = (t / 60) % 60
	var seconds = t % 60
	return "%02d:%02d" % [minutes, seconds]

func get_clean_text(val: float) -> String:
	var rounded_val = snapped(val, 0.1)
	if is_equal_approx(fmod(rounded_val, 1.0), 0.0):
		return str(int(rounded_val))
	else:
		return "%.1f" % rounded_val

# --- BUTTON SIGNALS ---
func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed():
	EnemyPool.clear_pools()
	XpPool.reset_pool()
	SceneChanger.change_scene("res://main/ui/general_menu/main_menu/main_menu.tscn")
