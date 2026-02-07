extends Control

@export var character_name: String
@export var character_scene: PackedScene
@export var sprite_frames: SpriteFrames
@export var unlocked: bool = true

func _ready():
	$Label.text = character_name
	$TextureButton.connect("pressed", Callable(self, "_on_pressed"))
	
	if sprite_frames:
		$TextureButton/CenterContainer/AnimatedSprite2D.sprite_frames = sprite_frames
		var anims = sprite_frames.get_animation_names()
		if anims.size() > 0:
			$TextureButton/CenterContainer/AnimatedSprite2D.play(anims[0])  # erste Animation automatisch abspielen

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


# Zurück Zum Hauptmenü
const SCENE_MAIN = "res://main/ui/general_menu/main_menu/main_menu.tscn"
# wenn go-back_button geklickt
func _on_button_back_pressed():
	if ResourceLoader.exists(SCENE_MAIN):
		# Ersetze die aktuelle Szene (MainMenu) durch  Zielszene (CharacterSeletion)
		get_tree().change_scene_to_file(SCENE_MAIN)
	else:
		# Falls  Pfad falsch ist
		print("FEHLER: Zielszene nicht gefunden unter: ", SCENE_MAIN)
