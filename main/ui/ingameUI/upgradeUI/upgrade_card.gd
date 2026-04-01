extends PanelContainer

signal selected()

@onready var title_label = $MarginContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var desc_label = $MarginContainer/MarginContainer/VBoxContainer/DescriptionLabel
@onready var rarity_label = $MarginContainer/MarginContainer/VBoxContainer/RarityLabel
@onready var icon_rect = $MarginContainer/MarginContainer/VBoxContainer/Icon

# --- STRAHLEN REFERENZEN ---
@onready var ray_anchor = $RayAnchor
@onready var legendary_rays = $RayAnchor/LegendaryRays

# --- DIE SOULS-LIKE PALETTE ---
var rarity_colors = {
	"Common": Color("#595959"),
	"Uncommon": Color("#5a6b52"),
	"Rare": Color("#3b5470"),
	"Epic": Color("#6e2b42"),
	"Legendary": Color("#d46a15")
}

var is_clicked: bool = false

func _ready():
	scale = Vector2.ZERO
	
	if material:
		material = material.duplicate()
		
	# Strahlen beim Start unsichtbar machen und zentrieren
	if ray_anchor and legendary_rays:
		ray_anchor.position = size / 2.0 
		legendary_rays.visible = false

func set_item_data(title: String, description: String, rarity: String, icon_texture: Texture2D = null):
	desc_label.text = description 
	rarity_label.text = rarity
	
	if icon_texture:
		icon_rect.texture = icon_texture
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.custom_minimum_size = Vector2(32, 32)
		
		# Verhindert, dass das Icon gequetscht wird!
		icon_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		icon_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER 
		
		var style_box = StyleBoxFlat.new()
		style_box.bg_color = Color(0.02, 0.02, 0.05, 1.0)
		style_box.border_width_bottom = 2
		style_box.border_width_top = 2
		style_box.border_width_left = 2
		style_box.border_width_right = 2
		style_box.border_color = rarity_colors.get(rarity, Color.GRAY)
		style_box.expand_margin_bottom = 4
		style_box.expand_margin_top = 4
		style_box.expand_margin_left = 4
		style_box.expand_margin_right = 4

		var bg_panel = icon_rect.get_node_or_null("BackgroundPanel")
		if bg_panel == null:
			bg_panel = Panel.new()
			bg_panel.name = "BackgroundPanel"
			bg_panel.show_behind_parent = true 
			bg_panel.set_anchors_preset(Control.PRESET_FULL_RECT) 
			icon_rect.add_child(bg_panel)
			
		bg_panel.add_theme_stylebox_override("panel", style_box)
		
	# --- TITEL LOGIK ---
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

	# --- SHADER LOGIK ---
	if legendary_rays:
		legendary_rays.visible = false # Erstmal sicherheitshalber ausschalten
		
	if material is ShaderMaterial:
		var mat = material as ShaderMaterial
		var col = rarity_colors.get(rarity, Color.WHITE)
		var intens = 0.0
		var dirt = 0.4 
		var shader_speed = 0.0
		rarity_label.modulate = col
		var rand_offset = randf() * 100.0 
		
		match rarity:
			"Common": 
				intens = 0.0
				dirt = 0.6 
				shader_speed = 0.0 
			"Uncommon": 
				intens = 0.0
				dirt = 0.4
				shader_speed = 0.0
			"Rare": 
				intens = 0.3
				dirt = 0.3
				shader_speed = 0.2
			"Epic": 
				intens = 0.6
				dirt = 0.2
				shader_speed = 0.4
			"Legendary": 
				intens = 1.0
				dirt = 0.1 
				shader_speed = 0.6
				# --- HIER WERDEN DIE STRAHLEN EINGESCHALTET ---
				if legendary_rays:
					legendary_rays.visible = true

		mat.set_shader_parameter("base_tint", col)
		mat.set_shader_parameter("intensity", intens)
		mat.set_shader_parameter("dirt_strength", dirt)
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
	
	if ray_anchor and legendary_rays:
		# Schiebt den Anker exakt in die Mitte der Karte
		ray_anchor.position = size / 2.0
		
		# Zentriert das Strahlen-Rechteck um den Anker herum!
		# Wir ziehen die Hälfte seiner eigenen Größe ab (z.B. bei 400x400 schieben wir es um -200, -200)
		legendary_rays.position = -(legendary_rays.size / 2.0)
	
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
