extends RangeWeapon

var projectile_count: int = 1
var piercing_count: int = 0


func get_upgrade_info(next_level: int) -> Dictionary:
	match next_level:
		2:
			return {
				"desc": "[color=green]+1 Piercing[/color]\nPiercing an additional Enemy.",
				"rarity": "Common"
			}
		3:
			return {
				"desc": "[color=green]+10 Base Damage[/color]\nMakes every hit count.",
				"rarity": "Rare"
			}
		4:
			return {
				"desc": "[color=green]+30% Projectile Speed[/color]\nKnives fly much faster.",
				"rarity": "Common"
			}
		5:
			return {
				"desc":
				"[color=green]+2 Piercing[/color]\n[color=red]Piercing 2 additional Enemies.[/color]",
				"rarity": "Epic"
			}
	return {"desc": "MAX", "rarity": "Common"}


func _apply_stats_for_current_level():
	match level:
		2:
			piercing_count += 1
		3:
			base_damage += 10.0
		4:
			projectile_speed *= 1.3
		5:
			piercing_count += 2

func attack() -> bool:
	var target = get_nearest_enemy()
	if not target:
		return false
	_fire_sequence(target)
	return true


func _fire_sequence(target):
	for i in range(projectile_count):
		if is_instance_valid(target):
			shoot_at(target)

		if projectile_count > 1:
			await get_tree().create_timer(0.1).timeout
