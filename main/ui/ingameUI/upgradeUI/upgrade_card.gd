extends PanelContainer

signal selected() # Signal, das wir senden, wenn die Karte geklickt wird

@onready var title_label = $MarginContainer/VBoxContainer/TitleLabel
@onready var desc_label = $MarginContainer/VBoxContainer/DescriptionLabel
@onready var rarity_label = $MarginContainer/VBoxContainer/RarityLabel
@onready var icon_rect = $MarginContainer/VBoxContainer/Icon
@onready var background_style = get_theme_stylebox("panel").duplicate()

# Farben für Raritäten
var rarity_colors = {
	"Common": Color.GRAY,
	"Rare": Color.DODGER_BLUE,
	"Legendary": Color.GOLD
}

func _ready():
	# Style duplizieren, damit wir die Farbe ändern können, ohne alle Karten zu ändern
	add_theme_stylebox_override("panel", background_style)

# Diese Funktion rufen wir später vom LevelUpScreen auf
func set_item_data(title, description, rarity, icon_texture = null):
	title_label.text = title
	desc_label.text = description
	rarity_label.text = rarity
	
	if icon_texture:
		icon_rect.texture = icon_texture
	
	# Rahmenfarbe je nach Rarität ändern
	if rarity in rarity_colors:
		background_style.border_color = rarity_colors[rarity]
		rarity_label.modulate = rarity_colors[rarity]

func _on_button_pressed():
	# Wenn geklickt, Animation abspielen oder direkt Signal senden
	emit_signal("selected")
	print("ausgewählt")
	
