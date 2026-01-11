extends PanelContainer

signal selected()

@onready var title_label = $MarginContainer/VBoxContainer/TitleLabel
@onready var desc_label = $MarginContainer/VBoxContainer/DescriptionLabel
@onready var rarity_label = $MarginContainer/VBoxContainer/RarityLabel
@onready var icon_rect = $MarginContainer/VBoxContainer/Icon
@onready var background_style = get_theme_stylebox("panel").duplicate()

var rarity_colors = {
	"Common": Color.GRAY,
	"Rare": Color.DODGER_BLUE,
	"Legendary": Color.GOLD
}

func _ready():
	add_theme_stylebox_override("panel", background_style)
	# WICHTIG: Sofort unsichtbar machen, ohne Wenn und Aber
	modulate.a = 0.0
	scale = Vector2.ZERO

func set_item_data(title, description, rarity, icon_texture = null):
	title_label.text = title
	desc_label.text = description
	rarity_label.text = rarity
	
	if icon_texture:
		icon_rect.texture = icon_texture
	
	if rarity in rarity_colors:
		var col = rarity_colors[rarity]
		self_modulate = col
		rarity_label.modulate = col

	# Shader Setup (hier gekürzt für Übersicht)
	var mat = material as ShaderMaterial
	if mat:
		mat = mat.duplicate()
		material = mat
		if rarity == "Legendary": mat.set_shader_parameter("intensity", 0.8)
		elif rarity == "Rare": mat.set_shader_parameter("intensity", 0.4)
		else: mat.set_shader_parameter("intensity", 0.0)

# --- DIE GEFIXTE ANIMATION ---
func appear(delay_time: float):
	# 1. Hartes Resetten der Werte (falls sie schon sichtbar waren)
	modulate.a = 0.0
	scale = Vector2.ZERO
	
	# 2. Warten, bis Layout wirklich da ist (2 Frames sind sicherer als einer!)
	if not is_inside_tree(): await ready
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 3. Jetzt Größe holen und Pivot setzen
	pivot_offset = Vector2(size.x / 2, size.y)
	
	# 4. Tween erstellen
	var tween = create_tween()
	
	# WICHTIG: Tweens hören standardmäßig auf Pause! 
	# Da dein Spiel pausiert ist, müssen wir sicherstellen, dass der Tween trotzdem läuft.
	# (Da dein Node "Always" oder "When Paused" hat, sollte es gehen, aber das hier erzwingt es:)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	# 5. Parallele Animation
	tween.set_parallel(true)
	
	# Die Verzögerung einbauen
	# Wir nutzen tween_property mit "delay" Parameter im Tween selbst, das ist stabiler als tween_interval
	
	# Alpha: Von 0 auf 1 in 0.3s, mit Start-Verzögerung
	tween.tween_property(self, "modulate:a", 1.0, 0.3).set_delay(delay_time)
	
	# Scale: Von 0 auf 1 mit Bounce, mit Start-Verzögerung
	# .from(Vector2.ZERO) erzwingt, dass es wirklich bei 0 startet
	tween.tween_property(self, "scale", Vector2.ONE, 0.5)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)\
		.set_delay(delay_time)\
		.from(Vector2.ZERO)
