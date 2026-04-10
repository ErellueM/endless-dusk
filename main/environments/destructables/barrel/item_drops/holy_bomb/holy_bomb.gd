extends BasePickup

@export var damage: float = 9999.0
@export var enemies_per_frame: int = 10


func _apply_effect(_player: Node2D):
	# 1. Kamera Wackeln
	var camera = get_tree().get_first_node_in_group("camera")
	if camera and camera.has_method("shake"):
		camera.shake(0.5, 15.0)

	var flash = ColorRect.new()
	flash.color = Color(1.0, 1.0, 0.8, 1.0)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	canvas_layer.add_child(flash)

	get_tree().current_scene.add_child(canvas_layer)

	var tween = flash.create_tween()
	tween.tween_property(flash, "color:a", 0.0, 0.8).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(canvas_layer.queue_free)

	DamagePool.wipe_enemies(damage, enemies_per_frame)
