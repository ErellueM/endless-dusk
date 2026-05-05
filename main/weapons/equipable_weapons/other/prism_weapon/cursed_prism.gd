extends Weapon
class_name PrismWeapon

@export var prism_scene: PackedScene
@export var trap_duration: float = 6.0
@export var tick_rate: float = 1.0 

func attack() -> bool:
	if not prism_scene or not player_ref:
		return false
		
	var prism = prism_scene.instantiate()
	get_tree().current_scene.add_child(prism)
	
	prism.global_position = player_ref.global_position
	
	prism.damage = get_actual_damage()
	prism.area_scale = get_actual_area()
	prism.duration = trap_duration
	prism.tick_rate = tick_rate
	prism.weapon_ref = self
	
	return true

# --- UPGRADE LOGIK ---
func get_upgrade_info(next_level: int) -> Dictionary:
	match next_level:
		2:
			return {
				"desc": "[color=green]+4 Base Damage[/color]\n[color=green]+2s Duration[/color]",
				"rarity": "Common"
			}
		3:
			return {
				"desc": "[color=green]+30% Area[/color]\nCovers a massive zone.",
				"rarity": "Uncommon"
			}
		4:
			return {
				"desc": "[color=green]Faster Pulses[/color]\n[color=green]-1.0s Drop Cooldown[/color]",
				"rarity": "Rare"
			}
		5:
			return {
				"desc": "[color=green]+8 Base Damage[/color]\n[color=green]+30% Area & +2s Duration[/color]",
				"rarity": "Legendary"
			}
	return {"desc": "MAX", "rarity": "Common"}

func _apply_stats_for_current_level():
	match level:
		1:
			base_damage = 6.0
			base_area = 1.0
			base_fire_rate = 6.0
			trap_duration = 6.0
			tick_rate = 1.0 
		2:
			base_damage += 4.0
			trap_duration = 8.0
		3:
			base_area *= 1.3
		4:
			tick_rate = 0.7 
			base_fire_rate -= 1.0 
		5:
			base_damage += 8.0
			base_area *= 1.3
			trap_duration = 10.0
