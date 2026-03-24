extends Node
class_name StatusManager

signal apply_tick_damage(amount: float, source: Node2D, color: Color)

var effects: Array[StatusEffect] = []
@onready var parent = get_parent()


var speed_mult: float = 1.0
var dmg_taken_mult: float = 1.0
var dmg_dealt_mult: float = 1.0
var color_mod: Color = Color(1, 1, 1)

func add_effect(new_effect: StatusEffect):
	if parent.get("immune_to_all_status") == true: return
	
	var immunities = parent.get("status_immunities")
	if typeof(immunities) == TYPE_ARRAY and new_effect.id in immunities: return
			
	for i in range(effects.size()):
		var e = effects[i]
		if e.id == new_effect.id:
			if new_effect.get_power() >= e.get_power():
				e.remove()
				new_effect.apply(parent)
				effects[i] = new_effect
			else:
				e.duration = max(e.duration, new_effect.duration)
			return 
			
	new_effect.apply(parent)
	effects.append(new_effect)

func remove_effect_by_id(effect_id: String):
	for i in range(effects.size() - 1, -1, -1):
		if effects[i].id == effect_id:
			effects[i].remove()
			effects.remove_at(i)
			

func _physics_process(delta):
	# Jeden Frame auf Normalwerte setzen
	speed_mult = 1.0
	dmg_taken_mult = 1.0
	dmg_dealt_mult = 1.0
	color_mod = Color(1, 1, 1)
	
	if effects.is_empty(): return
	
	for i in range(effects.size() - 1, -1, -1):
		var eff = effects[i]
		eff.tick(delta)
		
		# Werte aller aktiven Effekte zusammenrechnen
		speed_mult *= eff.get_speed_mult()
		dmg_taken_mult *= eff.get_dmg_taken_mult()
		color_mod *= eff.get_color()
		# (dmg_dealt_mult könnte man hier analog ergänzen, wenn Effekte das haben)
		
		if eff.duration <= 0:
			eff.remove()
			effects.remove_at(i)
