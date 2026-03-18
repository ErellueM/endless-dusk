extends RangeWeapon

var projectile_count: int = 1
var applies_poison: bool = false

func get_upgrade_info(next_level: int) -> Dictionary:
	match next_level:
		2: return {"desc": "[color=green]+1 Projectile[/color]\nFires an additional knife.", "rarity": "Common"}
		3: return {"desc": "[color=green]+10 Base Damage[/color]\nMakes every hit count.", "rarity": "Rare"}
		4: return {"desc": "[color=green]+20% Projectile Speed[/color]\nKnives fly much faster.", "rarity": "Common"}
		5: return {"desc": "[color=green]Apply Poison[/color]\n[color=red]Deals damage over time.[/color]", "rarity": "Legendary"}
	return {"desc": "MAX", "rarity": "Common"}

func _apply_stats_for_current_level():
	match level:
		2: projectile_count += 1
		3: base_damage += 10.0
		4: projectile_speed *= 1.2
		5: applies_poison = true

# --- DER FIX ---
func attack() -> bool:
	var target = get_nearest_enemy()
	if not target:
		return false
	
	# Wir rufen eine extra Funktion auf, die sich um das "Warten" kümmert
	# So kann die attack() Funktion sofort "true" zurückgeben!
	_fire_sequence(target)
	return true

# Diese Funktion läuft im Hintergrund ab
func _fire_sequence(target):
	for i in range(projectile_count):
		# Sicherheitsscheck: Lebt der Gegner noch?
		if is_instance_valid(target):
			shoot_at(target)
		
		if projectile_count > 1:
			await get_tree().create_timer(0.1).timeout
