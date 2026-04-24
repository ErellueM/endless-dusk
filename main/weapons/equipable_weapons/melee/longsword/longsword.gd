extends BaseMeleeWeapon

func get_upgrade_info(next_level: int) -> Dictionary:
	match next_level:
		2: return {"desc": "[color=green]+20% Area[/color]\nBigger blade.", "rarity": "Common"}
		3: return {"desc": "[color=green]+15 Base Damage[/color]", "rarity": "Rare"}
		4: return {"desc": "[color=green]-20% Cooldown[/color]\nSwings faster.", "rarity": "Uncommon"}
		5: return {"desc": "[color=green]220° Swing Arc[/color]\nWhirlwind attack!", "rarity": "Legendary"}
	return {"desc": "MAX", "rarity": "Common"}

func _apply_stats_for_current_level():
	match level:
		2: base_area += 0.20
		3: base_damage += 15.0
		4: base_fire_rate *= 0.8
		5: swing_arc_degrees = 220.0 # Hier sieht man die Macht deines Systems!
