extends BaseMeleeWeapon

func get_upgrade_info(next_level: int) -> Dictionary:
	match next_level:
		2: return {"desc": "[color=green]+20% Area[/color]\nLonger blade.", "rarity": "Common"}
		3: return {"desc": "[color=green]+10 Base Damage[/color]\n[color=green]-10% Cooldown[/color]", "rarity": "Uncommon"}
		4: return {"desc": "[color=green]+25% Area[/color]\nMassive swings.", "rarity": "Rare"}
		5: return {"desc": "[color=orange]Whirlwind Attack[/color]\n[color=green]240° Swing Arc & much faster![/color]", "rarity": "Legendary"}
	return {"desc": "MAX", "rarity": "Common"}

func _apply_stats_for_current_level():
	match level:
		2: base_area += 0.20
		3: 
			base_damage += 10.0
			base_fire_rate *= 0.9
		4: base_area += 0.25
		5: 
			swing_arc_degrees = 240.0
			base_fire_rate *= 0.7 # 30% schneller!
