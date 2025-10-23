extends Control

@export var character_name: String
@export var character_scene: PackedScene
@export var sprite_frames: SpriteFrames
@export var unlocked: bool = true

func _ready():
	$Label.text = character_name
	$TextureButton.connect("pressed", Callable(self, "_on_pressed"))
	
	if sprite_frames:
		$TextureButton/AnimatedSprite2D.sprite_frames = sprite_frames
		var anims = sprite_frames.get_animation_names()
		if anims.size() > 0:
			$TextureButton/AnimatedSprite2D.play(anims[0])  # erste Animation automatisch abspielen

	if not unlocked:
		make_locked_visual()

func _on_pressed():
	if not unlocked:
		return
	Global.selected_character_scene = character_scene
	get_tree().change_scene_to_file("res://maps/map_1.tscn")

func make_locked_visual():
	$TextureButton.modulate = Color(0, 0, 0, 0.5)
	$Label.text = "???"
