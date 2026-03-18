extends PanelContainer

signal selected()

@onready var title_label = $MarginContainer/MarginContainer/VBoxContainer/TitleLabel
# 🚨 WICHTIG: Das hier MUSS in der Szene ein RichTextLabel sein (mit Haken bei "Bbcode Enabled")!
@onready var desc_label = $MarginContainer/MarginContainer/VBoxContainer/DescriptionLabel
@onready var rarity_label = $MarginContainer/MarginContainer/VBoxContainer/RarityLabel
@onready var icon_rect = $MarginContainer/MarginContainer/VBoxContainer/Icon
@onready var background_style = get_theme_stylebox("panel").duplicate()

var rarity_colors = {
	"Common": Color.GRAY,
	"Rare": Color.DODGER_BLUE,
	"Legendary": Color.GOLD
}

# --- NEU: Spam-Schutz ---
var is_clicked: bool = false

func _ready():
	add_theme_stylebox_override("panel", background_style)
	modulate.a = 0.0
	scale = Vector2.ZERO

func set_item_data(title, description, rarity, icon_texture = null):
	title_label.text = title
	desc_label.text = description # Das funktioniert bei RichTextLabels automatisch mit Farben!
	rarity_label.text = rarity
	
	if icon_texture:
		icon_rect.texture = icon_texture
	
	if rarity in rarity_colors:
		var col = rarity_colors[rarity]
		self_modulate = col
		rarity_label.modulate = col

	var mat = material as ShaderMaterial
	if mat:
		mat = mat.duplicate()
		material = mat
		if rarity == "Legendary": mat.set_shader_parameter("intensity", 0.8)
		elif rarity == "Rare": mat.set_shader_parameter("intensity", 0.4)
		else: mat.set_shader_parameter("intensity", 0.0)

func appear(delay_time: float):
	modulate.a = 0.0
	scale = Vector2.ZERO
	is_clicked = false # Resetten, falls die Karte neu verwendet wird
	
	if not is_inside_tree(): await ready
	await get_tree().process_frame
	await get_tree().process_frame
	
	pivot_offset = Vector2(size.x / 2, size.y)
	
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel(true)
	
	tween.tween_property(self, "modulate:a", 1.0, 0.3).set_delay(delay_time)
	
	tween.tween_property(self, "scale", Vector2.ONE, 0.5)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)\
		.set_delay(delay_time)\
		.from(Vector2.ZERO)

func _on_button_pressed():
	# --- NEU: Der Spam-Schutz ---
	if is_clicked:
		return # Wenn schon geklickt wurde, ignoriere alle weiteren Klicks!
		
	is_clicked = true
	emit_signal("selected")
	print("ausgewählt: ", title_label.text)
