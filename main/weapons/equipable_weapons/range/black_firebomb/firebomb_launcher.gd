extends Weapon

@export var bomb_scene: PackedScene
@export var scatter_radius: float = 120.0

func attack() -> bool:
	if not bomb_scene: return false
	_spawn_bomb()
	return true

func _spawn_bomb():
	var bomb = bomb_scene.instantiate()
	bomb.global_position = global_position
	
	var random_dir = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var random_dist = randf_range(40.0, scatter_radius * get_actual_area())
	bomb.target_pos = global_position + (random_dir * random_dist)
	
	bomb.damage = get_actual_damage()
	bomb.weapon_ref = self
	
	get_tree().current_scene.add_child(bomb)

# --- UPGRADES ---
func get_upgrade_info(next_level: int) -> Dictionary:
	match next_level:
		2: return {"desc": "[color=green]+6 Base Damage[/color]\nDevastating impact.", "rarity": "Common"}
		3: return {"desc": "[color=green]+20% Explosion Radius[/color]", "rarity": "Uncommon"}
		4: return {"desc": "[color=green]-25% Cooldown[/color]", "rarity": "Rare"}
		5: return {"desc": "[color=orange]Chaos Fire[/color]\n[color=green]Explosions now ignite enemies![/color]", "rarity": "Legendary"}
	return {"desc": "MAX", "rarity": "Common"}

func _apply_stats_for_current_level():
	match level:
		2: base_damage += 6.0
		3: base_area += 0.20
		4: base_fire_rate *= 0.75
		5: pass # Logik ist im Projektil
