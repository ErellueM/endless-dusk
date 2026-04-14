class_name StatusManagerLight
extends RefCounted

# Wir brauchen Variablen für die Multiplikatoren
var speed_mult: float = 1.0
var dmg_taken_mult: float = 1.0
var color_mod: Color = Color(1, 1, 1)

var effects: Array = []
var parent: Node2D

func _init(_parent: Node2D):
	parent = _parent

func add_effect(new_effect: StatusEffect):
	# Immunitäts-Check (greift auf Variablen im SwarmEnemy zu)
	if parent.get("immune_to_all_status") == true:
		return
	
	# Vorhandene Effekte prüfen (Ersetzen oder Auffrischen)
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

func process_logic(delta: float):
	# Standardwerte für jeden Frame zurücksetzen
	speed_mult = 1.0
	dmg_taken_mult = 1.0
	color_mod = Color(1, 1, 1)

	if effects.is_empty():
		return

	for i in range(effects.size() - 1, -1, -1):
		var eff = effects[i]
		eff.tick(delta)

		# Werte kombinieren
		speed_mult *= eff.get_speed_mult()
		dmg_taken_mult *= eff.get_dmg_taken_mult()
		color_mod *= eff.get_color()

		if eff.duration <= 0:
			eff.remove()
			effects.remove_at(i)

# Hilfsfunktion für Gift/Netto-Rechnung (falls benötigt)
func get_total_poison_damage() -> float:
	var total = 0.0
	for e in effects:
		if e.has_method("get_damage_per_second"): # Falls dein Poison-Effekt das hat
			total += e.damage_per_tick / e.tick_rate
	return total
