extends Weapon
class_name PrismWeapon

@export var prism_scene: PackedScene
@export var trap_duration: float = 6.0
@export var tick_rate: float = 1.0 # Wie schnell das Prisma Schaden pulsiert

func attack() -> bool:
	if not prism_scene or not player_ref:
		return false
		
	var prism = prism_scene.instantiate()
	get_tree().current_scene.add_child(prism)
	
	# Das Prisma auf den Boden droppen
	prism.global_position = player_ref.global_position
	
	# Werte an das Prisma übergeben
	prism.damage = get_actual_damage()
	prism.area_scale = get_actual_area()
	prism.duration = trap_duration
	prism.tick_rate = tick_rate
	prism.weapon_ref = self
	
	return true

# --- UPGRADE LOGIK ---
func _apply_stats_for_current_level():
	match level:
		1:
			base_damage = 4
			base_area = 1.0
			base_fire_rate = 6
			trap_duration = 6.0
			tick_rate = 1.0 
		2:
			base_damage += 4
			trap_duration = 8.0
		3:
			base_area *= 1.3
		4:
			tick_rate = 0.7 
			base_fire_rate -=0.5 
		5:
			base_damage += 8
			base_area *= 1.3
			trap_duration = 10.0

func get_upgrade_info(next_level: int) -> Dictionary:
	match next_level:
		2:
			return {
				"desc": "[color=green]+4 Base Damage[/color]\n[color=green]+2s Duration[/color]\n",
				"rarity": "Common"
			}
		3:
			return {
				"desc": "[color=green]+30% Area[/color]\n",
				"rarity": "Uncommon"
			}
		4:
			return {
				"desc": "[color=green]Faster Pulses[/color]\n[color=green]-0.5s Cooldown[/color]\n",
				"rarity": "Rare"
			}
		5:
			return {
				"desc": "[color=green]+8 Base Damage[/color]\n[color=green]+30% Area[/color]\n[color=green]+2s Duration[/color]\n",
				"rarity": "Legendary"
			}
	return {"desc": "MAX", "rarity": "Common"}
