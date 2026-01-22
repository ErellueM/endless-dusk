extends CanvasLayer

# --- REFERENZEN (per Unique Name %) ---
@onready var content_control = %Control
@onready var stats_grid = %StatsGrid
@onready var weapons_grid = %WeaponsGrid

func _ready():
	# FEHLERBEHEBUNG:
	# Wir verbinden uns mit dem Signal DES CANVAS LAYERS selbst ("self").
	# Wenn der GameManager .show() aufruft, feuert dieses Signal hier.
	visibility_changed.connect(_on_visibility_changed)
	
	# WICHTIG: Lösche die Zeile "content_control.visible = false"
	# Der GameManager versteckt ja schon den ganzen CanvasLayer beim Start.
	# Das Control soll "offen" bleiben, damit es zu sehen ist, sobald der Layer angeht.

# Diese Funktion feuert, wenn der CanvasLayer sichtbar/unsichtbar wird
func _on_visibility_changed():
	# Wir prüfen "visible" (das ist die Eigenschaft dieses CanvasLayers)
	if visible:
		# Menü ist jetzt sichtbar -> UI updaten!
		# Optional: Falls das Control im Editor ausgeblendet war, schalten wir es an:
		content_control.visible = true 
		update_ui()

# --- HAUPTFUNKTION ---
func update_ui():
	# Wir suchen den Spieler
	var player = get_tree().get_first_node_in_group("player")
	
	if player:
		update_stats(player)
		update_weapons(player)

# --- TEIL A: STATS ---
func update_stats(player):
	# Alte Einträge löschen
	for child in stats_grid.get_children():
		child.queue_free()

	# 1. HEALTH
	var hp_text = str(int(player.current_health)) + " / " + str(int(player.max_health))
	add_stat_row("❤ Max Health", hp_text)
	
	# 2. ARMOR
	var armor_color = Color.GREEN if player.armor > 0 else Color.WHITE
	add_stat_row("🛡 Armor", get_clean_text(player.armor), armor_color)
	
	# 3. RECOVERY
	var rec_text = get_clean_text(player.recovery) + "/sec"
	var rec_color = Color.GREEN if player.recovery > 0 else Color.WHITE
	add_stat_row("💖 Recovery", rec_text, rec_color)
	
	add_separator(stats_grid)
	
	# 4. MIGHT (Schaden)
	var might_bonus = (player.might - 1.0) * 100
	var might_col = Color.GOLD if might_bonus > 0 else (Color.RED if might_bonus < 0 else Color.WHITE)
	add_stat_row("⚔ Might", get_clean_text(might_bonus) + "%", might_col)
	
	# 5. AREA
	var area_bonus = (player.area - 1.0) * 100
	var area_col = Color.GOLD if area_bonus > 0 else Color.WHITE
	add_stat_row("⭕ Area", get_clean_text(area_bonus) + "%", area_col)
	
	# 6. COOLDOWN (Negativ ist gut!)
	var cd_diff = (player.cooldown_mult - 1.0) * 100
	var cd_col = Color.GREEN if cd_diff < 0 else (Color.RED if cd_diff > 0 else Color.WHITE)
	add_stat_row("⏳ Cooldown", get_clean_text(cd_diff) + "%", cd_col)
	
	add_separator(stats_grid)
	
	# 7. UTILITY
	add_stat_row("👟 Speed", str(int(player.speed)))
	add_stat_row("🧲 Magnet", str(int(player.magnet_range)) + " px")
	
	# 8. GROWTH
	var growth_bonus = (player.growth - 1.0) * 100
	var growth_col = Color.GREEN if growth_bonus > 0 else Color.WHITE
	add_stat_row("🌱 Growth", get_clean_text(growth_bonus) + "%", growth_col)

# --- TEIL B: WAFFEN ---
func update_weapons(player):
	for child in weapons_grid.get_children():
		child.queue_free()
	
	var found_weapons = false
	
	# Flexible Suche nach Waffen im Spieler-Node
	for child in player.get_children():
		# Prüft auf typische Waffeneigenschaften
		if child.has_method("shoot") or child.get("damage") != null or "Weapon" in child.name:
			var w_name = child.name
			# Versucht Schaden auszulesen, sonst "?"
			var w_dmg = "Dmg: " + str(child.get("damage")) if child.get("damage") else "Dmg: ?"
			
			add_weapon_entry(w_name, w_dmg)
			found_weapons = true
	
	if not found_weapons:
		var lbl = Label.new()
		lbl.text = "- Keine Waffen -"
		lbl.modulate = Color(0.5, 0.5, 0.5)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		weapons_grid.add_child(lbl)

# --- HILFSFUNKTIONEN ---

func get_clean_text(val: float) -> String:
	if is_equal_approx(fmod(val, 1.0), 0.0):
		return str(int(val)) # Ganze Zahl (50)
	else:
		return "%.1f" % val # Kommazahl (12.5)

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

# --- BUTTON SIGNALE ---

func _on_resume_button_pressed():
	var manager = get_tree().get_first_node_in_group("Managers")
	
	# Fallback, falls der Pfad anders ist (z.B. absolute Pfade)
	if not manager:
		print("FEHLER: GameManager nicht gefunden! Pfad im Script prüfen.")
		
	if manager:
		manager.change_state(manager.GameState.PLAYING)

func _on_quit_button_pressed():
	get_tree().quit()
