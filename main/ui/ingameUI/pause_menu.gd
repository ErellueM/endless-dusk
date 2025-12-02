extends CanvasLayer

# Wir nutzen Unique Names (%), damit Godot die Nodes automatisch findet,
# egal wie tief sie im MarginContainer verschachtelt sind.
@onready var content_control = $Control
@export var stats_grid: GridContainer 
@export var weapons_grid: GridContainer

var is_paused = false

func _ready():
	# Menü beim Start unsichtbar machen
	content_control.visible = false

# Auf ESC oder P hören
func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause():
	is_paused = !is_paused
	
	if is_paused:
		# Spiel einfrieren (TimeScale = 0)
		get_tree().paused = true
		content_control.visible = true
		
		# UI sofort mit aktuellen Daten füllen
		update_ui()
	else:
		# Spiel weiterlaufen lassen
		get_tree().paused = false
		content_control.visible = false

# Hauptfunktion: Ruft Stats und Waffen Updates auf
func update_ui():
	# Wir suchen den Spieler in der Gruppe "Player"
	var player = get_tree().get_first_node_in_group("player")
	
	if player:
		update_stats(player)
		update_weapons(player)

# --- TEIL A: STATS (Clean Formatierung) ---
func update_stats(player):
	# Alles löschen
	for child in stats_grid.get_children():
		child.queue_free()

	# --- SURVIVAL ---
	# Health: Ganz einfach "100 / 100"
	var hp_text = str(int(player.current_health)) + " / " + str(int(player.max_health))
	add_stat_row("❤ Max Health", hp_text)
	
	# Armor: Zeigt "0" oder "5" (ohne Plus)
	var armor_color = Color.GREEN if player.armor > 0 else Color.WHITE
	add_stat_row("🛡 Armor", get_clean_text(player.armor), armor_color)
	
	# Recovery: Zeigt "0/sec" oder "1.5/sec" (ohne Plus)
	var rec_text = get_clean_text(player.recovery) + "/sec"
	var rec_color = Color.GREEN if player.recovery > 0 else Color.WHITE
	add_stat_row("💖 Recovery", rec_text, rec_color)
	
	add_separator(stats_grid)
	
	# --- OFFENSIVE ---
	# Might: Wir berechnen den Bonus.
	# 1.0 -> 0%
	# 1.5 -> 50%
	# 0.9 -> -10% (Minus kommt automatisch durch die Rechnung)
	var might_bonus = (player.might - 1.0) * 100
	var might_col = Color.GOLD if might_bonus > 0 else (Color.RED if might_bonus < 0 else Color.WHITE)
	add_stat_row("⚔ Might", get_clean_text(might_bonus) + "%", might_col)
	
	# Area
	var area_bonus = (player.area - 1.0) * 100
	var area_col = Color.GOLD if area_bonus > 0 else Color.WHITE
	add_stat_row("⭕ Area", get_clean_text(area_bonus) + "%", area_col)
	
	# Cooldown: 
	# 1.0 -> 0%
	# 0.9 -> -10% (Minus zeigt an, dass der Cooldown reduziert ist -> Gut!)
	# Wir rechnen: (NeuerWert - Original) * 100
	var cd_diff = (player.cooldown_mult - 1.0) * 100
	# Wenn negativ (z.B. -10%), ist das gut -> Grün
	var cd_col = Color.GREEN if cd_diff < 0 else (Color.RED if cd_diff > 0 else Color.WHITE)
	add_stat_row("⏳ Cooldown", get_clean_text(cd_diff) + "%", cd_col)
	
	add_separator(stats_grid)
	
	# --- UTILITY ---
	add_stat_row("👟 Speed", str(int(player.speed)))
	add_stat_row("🧲 Magnet", str(int(player.magnet_range)) + " px")
	
	# Growth
	var growth_bonus = (player.growth - 1.0) * 100
	var growth_col = Color.GREEN if growth_bonus > 0 else Color.WHITE
	add_stat_row("🌱 Growth", get_clean_text(growth_bonus) + "%", growth_col)

# --- HILFSFUNKTION (Entfernt .0 und lässt Vorzeichen wie sie sind) ---
func get_clean_text(val: float) -> String:
	# Schritt 1: Runden auf 1 Nachkommastelle, um 99.9999 zu vermeiden
	# Schritt 2: Prüfen ob Ganzzahl
	
	if is_equal_approx(fmod(val, 1.0), 0.0):
		# Es ist eine glatte Zahl (z.B. 50.0 oder -10.0) -> ".0" abschneiden
		return str(int(val))
	else:
		# Es ist eine Kommazahl (z.B. 12.5) -> Zeige 1 Nachkommastelle
		return "%.1f" % val

# Erweiterte Row-Funktion mit optionaler Farbe
func add_stat_row(name_text: String, value_text: String, value_color: Color = Color.WHITE):
	var lbl_name = Label.new()
	lbl_name.text = name_text
	lbl_name.modulate = Color(0.8, 0.8, 0.8) # Leicht abgedunkelt
	stats_grid.add_child(lbl_name)
	
	var lbl_val = Label.new()
	lbl_val.text = value_text
	
	# Layout Einstellungen
	lbl_val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lbl_val.size_flags_horizontal = Control.SIZE_SHRINK_END # Rechtsbündig, ohne Dehnen
	
	# Hier setzen wir die Farbe (Grün, Gold, Rot, etc.)
	lbl_val.modulate = value_color
	
	stats_grid.add_child(lbl_val)

# Fügt einen leeren Abstand ein (braucht 2 Kinder wegen Grid-Spalten)
func add_separator(target_grid):
	var spacer_left = Control.new()
	target_grid.add_child(spacer_left)
	
	var spacer_right = Control.new()
	spacer_right.custom_minimum_size.y = 16 # Abstandshöhe in Pixeln
	target_grid.add_child(spacer_right)

# --- TEIL B: WAFFEN (Rechte Seite) ---
func update_weapons(player):
	# Alte Einträge löschen
	for child in weapons_grid.get_children():
		child.queue_free()
	
	var found_weapons = false
	
	# Sucht nach Nodes beim Spieler, die nach Waffe aussehen
	# (Passt sich automatisch an, wenn dein Teammate soweit ist)
	for child in player.get_children():
		# Wir prüfen einfach, ob das Kind eine "damage" Variable oder Gruppe hat
		if child.has_method("shoot") or child.get("damage") != null or "Weapon" in child.name:
			# Name und Infos extrahieren (Fallback Werte falls nicht vorhanden)
			var w_name = child.name
			var w_dmg = "Dmg: " + str(child.get("damage")) if child.get("damage") else "Dmg: ?"
			
			add_weapon_entry(w_name, w_dmg)
			found_weapons = true
	
	if not found_weapons:
		var lbl = Label.new()
		lbl.text = "- Keine Waffen -"
		lbl.modulate = Color(0.5, 0.5, 0.5)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		weapons_grid.add_child(lbl)

# Erzeugt einen Eintrag in der Waffenliste
func add_weapon_entry(w_name, w_info):
	var row = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var lbl_n = Label.new()
	lbl_n.text = "⚔ " + w_name # Kleines Schwert-Icon davor
	lbl_n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(lbl_n)
	
	var lbl_i = Label.new()
	lbl_i.text = w_info
	lbl_i.modulate = Color(1, 0.8, 0.2) # Goldene Farbe
	row.add_child(lbl_i)
	
	weapons_grid.add_child(row)

# --- TEIL C: BUTTONS ---
# Vergiss nicht, die Signale im Editor zu verbinden!

func _on_resume_button_pressed():
	toggle_pause()

func _on_settings_button_pressed():
	# Hier später Popup öffnen
	print("Settings geklickt")

func _on_quit_button_pressed():
	get_tree().quit()
