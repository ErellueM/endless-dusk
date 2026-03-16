extends Node2D

@onready var label = $Label

var stored_damage: float = 0
var stored_is_player: bool = false

func setup(damage_amount: float, is_player: bool = false):
	stored_damage = damage_amount
	stored_is_player = is_player

func _ready():
	label.text = str(int(stored_damage))
	
	if stored_is_player:
		label.modulate = Color(1.0, 0.2, 0.2)
	else:
		label.modulate = Color(1.0, 1.0, 0)
	animate_number()

func animate_number():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position", position + Vector2(0, -20), 3).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate:a", 0.0, 1.2).set_trans(Tween.TRANS_SINE)
	tween.chain().tween_callback(queue_free)
