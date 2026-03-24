class_name SlowEffect extends StatusEffect

var slow_amount: float
var ice_color: Color

func _init(_duration: float, _slow: float, _color: Color):
	super("ice_slow", _duration, null, false) 
	slow_amount = _slow
	ice_color = _color

func get_speed_mult() -> float:
	return slow_amount

func get_color() -> Color:
	return ice_color

func get_power() -> float:
	return 1.0 - slow_amount
