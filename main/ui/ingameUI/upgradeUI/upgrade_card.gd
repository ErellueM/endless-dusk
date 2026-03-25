extends PanelContainer

signal selected()

@onready var title_label = $MarginContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var desc_label = $MarginContainer/MarginContainer/VBoxContainer/DescriptionLabel
@onready var rarity_label = $MarginContainer/MarginContainer/VBoxContainer/RarityLabel
@onready var icon_rect = $MarginContainer/MarginContainer/VBoxContainer/Icon

# --- DIE SOULS-LIKE PALETTE ---
var rarity_colors = {
	"Common": Color("#595959"),    # Kaltes Eisen
	"Uncommon": Color("#5a6b52"),  # Angelaufene Bronze
	"Rare": Color("#3b5470"),      # Abgrund Seelenblau
	"Epic": Color("#6e2b42"),      # Dunkles Verderbnis-Rot
	"Legendary": Color("#d46a15")  # Boss-Glut
}

var is_clicked: bool = false

func _ready():
	scale = Vector2.ZERO
	
	if material:
		material = material.duplicate()

func set_item_data(title: String, description: String, rarity: String, icon_texture: Texture2D = null):
	desc_label.text = description 
	rarity_label.text = rarity
	
	if icon_texture:
		icon_rect.texture = icon_texture
	
	# --- LEGENDARY TITEL EFFEKT (BBCode) ---
	# Alle anderen bleiben komplett statisch und clean!
	if title_label is RichTextLabel:
		match rarity:
			"Legendary":
				title_label.text = "[center][pulse color=#ffaa00 height=-0.05 freq=2.0]" + title + "[/pulse][/center]"
			"Epic":
				title_label.text = "[center][color=#e8a2b5]" + title + "[/color][/center]"
			"Rare":
				title_label.text = "[center][color=#a2c2e8]" + title + "[/color][/center]"
			_:
				title_label.text = "[center]" + title + "[/center]"

	# --- SHADER ANSTEUERN ---
	if material is ShaderMaterial:
		var mat = material as ShaderMaterial
		var col = rarity_colors.get(rarity, Color.WHITE)
		
		var intens = 0.0
		var dirt = 0.4 
		var shader_speed = 0.0 # NEU: Individuelle Animations-Geschwindigkeit
		
		rarity_label.modulate = col
		
		# Zufällige Zahl generieren (z.B. 42.7), damit das Shader-Muster verschoben wird
		var rand_offset = randf() * 100.0 
		
		match rarity:
			"Common": 
				intens = 0.0
				dirt = 0.6 
				shader_speed = 0.0  # Keine Bewegung
			"Uncommon": 
				intens = 0.0
				dirt = 0.4
				shader_speed = 0.0  # Keine Bewegung
			"Rare": 
				intens = 0.3
				dirt = 0.3
				shader_speed = 0.2  # Sehr langsames Kriechen
			"Epic": 
				intens = 0.6
				dirt = 0.2
				shader_speed = 0.4  # Etwas lebhafter
			"Legendary": 
				intens = 1.0
				dirt = 0.1 
				shader_speed = 0.6  # Am schnellsten, aber immer noch ruhig und wuchtig

		mat.set_shader_parameter("base_tint", col)
		mat.set_shader_parameter("intensity", intens)
		mat.set_shader_parameter("dirt_strength", dirt)
		
		# Die neuen Werte an den Shader übergeben
		mat.set_shader_parameter("speed", shader_speed)
		mat.set_shader_parameter("random_offset", rand_offset)

func appear(delay_time: float):
	modulate.a = 0.0
	scale = Vector2.ZERO
	is_clicked = false 
	
	if not is_inside_tree(): await ready
	await get_tree().process_frame
	await get_tree().process_frame
	
	pivot_offset = size / 2.0
	
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel(true)
	
	tween.tween_property(self, "modulate:a", 1.0, 0.3).set_delay(delay_time)
	
	tween.tween_property(self, "scale", Vector2.ONE, 0.4)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)\
		.set_delay(delay_time)\
		.from(Vector2.ZERO)

func _on_button_pressed():
	if is_clicked:
		return 
		
	is_clicked = true
	selected.emit()
