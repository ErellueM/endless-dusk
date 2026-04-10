class_name VulnerableEffect extends StatusEffect

var damage_taken_multiplier: float


func _init(_duration: float, _multiplier: float):
	super("vulnerable", _duration, null, false)
	damage_taken_multiplier = _multiplier


func get_dmg_taken_mult() -> float:
	return damage_taken_multiplier


func get_color() -> Color:
	return Color(0.8, 0.2, 0.8)


func get_power() -> float:
	return damage_taken_multiplier
