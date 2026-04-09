extends Node2D

@onready var label = $Label
var active_tween: Tween = null 

func _ready():
	add_to_group("DamageNumber")

func setup_and_play(damage_amount: float, is_dot: bool, dmg_color: Color):
	if label == null:
		label = $Label
		
	if active_tween and active_tween.is_valid():
		active_tween.kill()
		
	label.position = Vector2.ZERO 
	label.scale = Vector2.ZERO 
	modulate.a = 1.0 
	
	if fmod(damage_amount, 1.0) == 0.0:
		label.text = "[center]" + str(int(damage_amount)) + "[/center]"
	else:
		var int_part = str(int(damage_amount))
		var dec_part = str(int(damage_amount * 10))[-1] 
		label.text = "[center]" + int_part + "[font_size=12]." + dec_part + "[/font_size][/center]"
	
	label.modulate = dmg_color
	
	show() 
	
	var travel = -35 if is_dot else -25 
	
	active_tween = create_tween()
	active_tween.set_parallel(true)
	
	active_tween.tween_property(label, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	active_tween.tween_property(label, "position", Vector2(0, travel), 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	active_tween.tween_property(self, "modulate:a", 0.0, 0.3).set_delay(0.4)
	active_tween.chain().tween_callback(func(): DamagePool.return_to_pool(self))
