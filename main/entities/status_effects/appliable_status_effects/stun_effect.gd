class_name StunEffect extends StatusEffect


func _init(_duration: float):
	super("stun", _duration, null, false)


func get_speed_mult() -> float:
	return 0.0


func get_color() -> Color:
	return Color(0.5, 0.5, 0.5)


func get_power() -> float:
	return 100.0
