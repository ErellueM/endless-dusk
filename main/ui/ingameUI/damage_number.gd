extends Node2D

@onready var label = $Label

var stored_damage: float = 0
var stored_is_player: bool = false
var stored_is_poison: bool = false

func setup(damage_amount: float, is_player: bool = false, is_poison: bool = false):
	stored_damage = damage_amount
	stored_is_player = is_player
	stored_is_poison = is_poison

func _ready():
	label.text = str(int(stored_damage))
	
	if stored_is_player:
		label.modulate = Color(1.0, 0.2, 0.2)
	elif stored_is_poison:
		label.modulate = Color(0.3, 1.0, 0.3)
	else:
		label.modulate = Color(1.0, 1.0, 0)
		
	animate_number()

func animate_number():
	var tween = create_tween()
	tween.set_parallel(true)
	var travel = -30 if stored_is_poison else -20
	
	tween.tween_property(self, "position", position + Vector2(0, travel), 1.2).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate:a", 0.0, 1.2).set_trans(Tween.TRANS_SINE)
	tween.chain().tween_callback(queue_free)
