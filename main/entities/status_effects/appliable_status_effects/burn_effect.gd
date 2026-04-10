class_name BurnEffect extends StatusEffect

var damage_per_tick: float
var tick_rate: float
var _tick_timer: float


func _init(_duration: float, _dmg_per_tick: float, _tick_rate: float, _source: Node2D = null):
	# "burn" ist die ID. Das 'true' am Ende sagt: Stacke pro Waffe!
	super("burn", _duration, _source, true)
	damage_per_tick = _dmg_per_tick
	tick_rate = _tick_rate
	_tick_timer = tick_rate


func tick(delta: float):
	super.tick(delta)

	_tick_timer -= delta
	if _tick_timer <= 0:
		if target.has_method("take_damage_typed"):
			var actual_dmg = target.take_damage_typed(damage_per_tick, true, get_color())
			if source and is_instance_valid(source) and source.has_method("add_damage_stat"):
				source.add_damage_stat(actual_dmg)

		_tick_timer = tick_rate


func get_color() -> Color:
	return Color(1.0, 0.4, 0.0)


# Stärke = Schaden pro Sekunde (fairer Vergleich bei verschiedenen Tick-Raten)
func get_power() -> float:
	return damage_per_tick / tick_rate
