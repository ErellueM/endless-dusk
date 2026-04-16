extends Control

signal character_clicked(char_node)

@export var character_name: String
@export var character_scene: PackedScene
@export var sprite_frames: SpriteFrames
@export var unlock_cost: int = 500 

var is_unlocked: bool = false

@onready var anim_sprite = $TextureButton/CenterContainer/AnimatedSprite2D
@onready var name_label = $InfoContainer/NameLabel
@onready var price_box = $InfoContainer/PriceBox
@onready var price_label = $InfoContainer/PriceBox/PriceLabel

func _ready():
	$TextureButton.pressed.connect(_on_pressed)
	
	if sprite_frames:
		anim_sprite.sprite_frames = sprite_frames
		var anims = sprite_frames.get_animation_names()
		if anims.size() > 0:
			anim_sprite.play(anims[0])

func setup():
	is_unlocked = Global.unlocked_characters.has(character_name)
	
	if is_unlocked:
		# FREIGESCHALTET
		anim_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0) # Normale Farbe
		name_label.text = character_name
		name_label.show()
		price_box.hide()
	else:
		# GESPERRT (Silhouetten-Look)
		anim_sprite.modulate = Color(0.0, 0.0, 0.0, 0.5) # Sehr dunkles Grau
		name_label.hide()
		price_label.text = str(unlock_cost)
		price_box.show()

func _on_pressed():
	character_clicked.emit(self)
