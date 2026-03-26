extends TextureButton

@onready var default_color = modulate

func _ready():
	modulate = default_color

func _on_mouse_entered():
	modulate = Color(1.0, 0.3, 0.3)

func _on_mouse_exited():
	modulate = default_color

func _on_button_down():
	modulate = Color(0.7, 0.0, 0.0)

func _on_button_up():
	modulate = Color(1.0, 0.3, 0.3)
	
func _on_smart_pressed():
	if owner and "is_overlay" in owner and owner.is_overlay:
		owner.queue_free()
	else:
		if has_node("/root/SceneChanger"):
			SceneChanger.go_back()
		else:
			print("FEHLER: SceneChanger nicht gefunden!")
