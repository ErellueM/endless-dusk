extends Area2D

@export var is_boss_grave: bool = false

var is_opened: bool = false

@onready var lid = $Lid
@onready var glow_light = $PointLight2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if body.is_in_group("player") and not is_opened:
		is_opened = true
		open_grave()

func open_grave():
	var camera = get_tree().get_first_node_in_group("camera")
	if camera and camera.has_method("shake"):
		camera.shake(0.3, 5.0) 
		
	var open_tween = create_tween().set_parallel(true)
	var target_pos = lid.position + Vector2(18, 4)
	open_tween.tween_property(lid, "position", target_pos, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	if glow_light:
		open_tween.tween_property(glow_light, "energy", 3, 0.5).set_trans(Tween.TRANS_SINE)
		
	open_tween.chain().tween_callback(spawn_loot)
	open_tween.chain().tween_callback(disappear_fancy)

func spawn_loot():
	var manager = get_tree().get_first_node_in_group("Managers")
	if manager and manager.has_method("trigger_chest_loot"):
		manager.trigger_chest_loot(is_boss_grave)

func disappear_fancy():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.5).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.chain().tween_callback(queue_free)
