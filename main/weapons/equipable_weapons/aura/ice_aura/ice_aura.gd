extends AuraWeapon

@export var slowness_factor: float = 0.5
var ice_color = Color(0.5, 0.5, 1.0) 
var base_radius: float = 50.0 

func get_upgrade_info(next_level: int) -> Dictionary:
	match next_level:
		2: return {
			"desc": "[color=green]+20% Area[/color]\nLarger freezing zone", 
			"rarity": "Common"
		}
		3: return {
			"desc": "[color=green]+15% Slow Power[/color]\nEnemies move slower", 
			"rarity": "Rare"
		}
	return {"desc": "MAX", "rarity": "Common"}

func _apply_stats_for_current_level():
	match level:
		2: base_area *= 1.2
		3: slowness_factor -= 0.15 # Stärkerer Slow

func apply_enter_effect(body: Node2D):
	if body.has_method("add_status_effect"):
		body.add_status_effect("ice_slow", {
			"slow_factor": slowness_factor,
			"color": ice_color
		})

func apply_exit_effect(body: Node2D):
	if body.has_method("remove_status_effect"):
		body.remove_status_effect("ice_slow")

func _draw():
	var inner_color = Color(0.2, 0.5, 1.0, 0.1) 
	draw_circle(Vector2.ZERO, base_radius, inner_color)
	var outline_color = Color(0.1, 0.4, 1.0, 0.1)
	draw_arc(Vector2.ZERO, base_radius, 0, TAU, 64, outline_color, 1.0, true)
