extends Node2D

@onready var label = $Label

var stored_damage: float = 0
var stored_is_player: bool = false
var stored_is_dot: bool = false 
var stored_color: Color = Color(1, 1, 0)

func setup(damage_amount: float, is_player: bool = false, is_dot: bool = false, dmg_color: Color = Color(1, 1, 0)):
	stored_damage = damage_amount
	stored_is_player = is_player
	stored_is_dot = is_dot
	stored_color = dmg_color

func _ready():
	label.text = str(int(stored_damage))
	
	#if stored_is_player:
	#	label.modulate = Color(1.0, 0.2, 0.2)
	#else:
	label.modulate = stored_color 
		
	animate_number()

func animate_number():
	var tween = create_tween()
	tween.set_parallel(true)
	var travel = -30 if stored_is_dot else -20
	
	tween.tween_property(self, "position", position + Vector2(0, travel), 1.2).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate:a", 0.0, 1.2).set_trans(Tween.TRANS_SINE)
	tween.chain().tween_callback(queue_free)
