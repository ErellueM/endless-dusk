extends Weapon

@export var fireball_scene: PackedScene
@export var projectile_speed: float = 300.0


func attack() -> bool:
	var target = _get_closest_enemy()
	if not target or not fireball_scene: 
		return false

	var target_dir = global_position.direction_to(target.global_position)
	if target_dir.length() < 0.01: 
		target_dir = Vector2.RIGHT
	var fireball = fireball_scene.instantiate()
	fireball.global_position = global_position
	
	fireball.velocity = target_dir * projectile_speed
	fireball.damage = get_actual_damage()
	fireball.weapon_ref = self
	fireball.scale = Vector2(get_actual_area(), get_actual_area())
	fireball.rotation = target_dir.angle() 
	
	get_tree().current_scene.add_child(fireball)
	return true

func _get_closest_enemy() -> Node2D:
	var targets = get_tree().get_nodes_in_group("Enemygroup") + get_tree().get_nodes_in_group("Props")
	var closest = null
	var min_dist = get_actual_range()
	for t in targets:
		if is_instance_valid(t) and t.visible and not t.get("is_dead"):
			var dist = global_position.distance_to(t.global_position)
			if dist < min_dist:
				min_dist = dist
				closest = t
	return closest

# --- UPGRADES ---
func get_upgrade_info(next_level: int) -> Dictionary:
	match next_level:
		2: return {"desc": "[color=green]-20% Cooldown[/color]\nFires more frequently.", "rarity": "Common"}
		3: return {"desc": "[color=green]+10 Base Damage[/color]\nHotter flames.", "rarity": "Rare"}
		4: return {"desc": "[color=green]+25% Projectile Speed[/color]\nFaster cast speed.", "rarity": "Common"}
		5: return {"desc": "[color=green]+30% Area, +15 Damage[/color]\nInferno unleashed.", "rarity": "Legendary"}
	return {"desc": "MAX", "rarity": "Common"}

func _apply_stats_for_current_level():
	match level:
		2: base_fire_rate *= 0.8
		3: base_damage += 10.0
		4: projectile_speed *= 1.25
		5:
			base_area += 0.30
			base_damage += 15.0
