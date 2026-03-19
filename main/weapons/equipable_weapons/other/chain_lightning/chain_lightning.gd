extends Weapon # Erbt von der Basis-Klasse!

@export_group("Lightning Specifics")
@export var max_bounces: int = 3
@export var bounce_range: float = 150.0

@onready var lightning_line = $LightningLine

func _ready():
	if lightning_line:
		lightning_line.clear_points()
		lightning_line.top_level = true 
		lightning_line.global_position = Vector2.ZERO

func attack() -> bool:
	var targets = get_chain_targets()
	
	if targets.size() == 0:
		return false
		
	var dmg = get_actual_damage()
	
	for enemy in targets:
		if enemy.has_method("take_damage"):
			enemy.take_damage(dmg)
			add_damage_stat(dmg)
			
	draw_lightning(targets)
	return true

func get_chain_targets() -> Array:
	var hits = []
	var current_pos = global_position 
	var all_enemies = get_tree().get_nodes_in_group("Enemygroup")
	
	for i in range(max_bounces + 1):
		var closest_enemy = null
		var min_dist = get_actual_range() if i == 0 else bounce_range
		
		for enemy in all_enemies:
			if enemy in hits or enemy.get("is_dead"):
				continue
				
			var dist = current_pos.distance_to(enemy.global_position)
			if dist < min_dist:
				min_dist = dist
				closest_enemy = enemy
				
		if closest_enemy:
			hits.append(closest_enemy)
			current_pos = closest_enemy.global_position 
		else:
			break 
			
	return hits

func draw_lightning(targets: Array):
	if not lightning_line: return
	
	lightning_line.clear_points()
	var current_point = global_position
	lightning_line.add_point(current_point)
	
	for enemy in targets:
		var target_point = enemy.global_position
		add_jagged_segments(current_point, target_point)
		current_point = target_point
		
	lightning_line.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(lightning_line, "modulate:a", 0.0, 0.25).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_callback(lightning_line.clear_points)

func add_jagged_segments(start: Vector2, end: Vector2):
	var segments = 3 
	var direction = (end - start).normalized()
	var distance = start.distance_to(end)
	var step_length = distance / segments
	
	for i in range(1, segments):
		var base_point = start + direction * (step_length * i)
		var perpendicular = Vector2(-direction.y, direction.x)
		var random_offset = perpendicular * randf_range(-15.0, 15.0)
		lightning_line.add_point(base_point + random_offset)
		
	lightning_line.add_point(end)

func get_upgrade_info(next_level: int) -> Dictionary:
	match next_level:
		2: return {"desc": "[color=green]+1 Max Bounces[/color]\nHits an extra target.", "rarity": "Common"}
		3: return {"desc": "[color=green]+10 Base Damage[/color]", "rarity": "Rare"}
		4: return {"desc": "[color=green]+50 Bounce Range[/color]\nJumps further.", "rarity": "Common"}
		5: return {"desc": "[color=green]+2 Max Bounces[/color]\nChain lightning storm!", "rarity": "Legendary"}
	return {"desc": "MAX", "rarity": "Common"}

func _apply_stats_for_current_level():
	match level:
		2: max_bounces += 1
		3: base_damage += 10.0
		4: bounce_range += 50.0
		5: max_bounces += 2
