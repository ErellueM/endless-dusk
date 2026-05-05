extends Weapon

@export_group("Lightning Specifics")
@export var max_bounces: int = 3
@export var bounce_range: float = 150.0

@onready var lightning_line = $LightningLine

func _ready():
	if lightning_line:
		lightning_line.clear_points()
		lightning_line.top_level = true
		lightning_line.global_position = Vector2.ZERO
		lightning_line.z_index = 100

func attack() -> bool:
	var target_positions = get_chain_target_positions()

	if target_positions.size() == 0:
		if lightning_line: lightning_line.clear_points()
		return false

	draw_lightning(target_positions)
	return true

func get_chain_target_positions() -> Array:
	var positions = []
	var hits_objects = []
	var current_pos = global_position

	var raw_targets = get_tree().get_nodes_in_group("Enemygroup") + get_tree().get_nodes_in_group("Props")
	var active_targets = []

	for t in raw_targets:
		if is_instance_valid(t) and t.visible and not t.get("is_dead"):
			active_targets.append(t)

	if active_targets.size() == 0:
		return positions

	var dmg = get_actual_damage()

	for i in range(max_bounces + 1):
		var closest_target = null
		# WICHTIG: Das Area-Upgrade beeinflusst jetzt auch den Kettenblitz-Sprung!
		var min_dist = get_actual_range() if i == 0 else (bounce_range * get_actual_area())

		for target in active_targets:
			if target in hits_objects:
				continue

			var dist = current_pos.distance_to(target.global_position)
			if dist < min_dist:
				min_dist = dist
				closest_target = target

		if closest_target:
			positions.append(closest_target.global_position)
			hits_objects.append(closest_target)
			current_pos = closest_target.global_position
			
			if closest_target.has_method("take_damage"):
				var actual_dmg = closest_target.take_damage(dmg, true)
				add_damage_stat(actual_dmg)
				
				# (Optional) Level 5 Spezial-Effekt: Stun!
				if level >= 5 and closest_target.has_method("add_status_effect"):
					closest_target.add_status_effect(StunEffect.new(0.5))
		else:
			break

	return positions

func draw_lightning(target_positions: Array):
	if not lightning_line:
		return

	lightning_line.clear_points()
	
	var start_pos = global_position
	lightning_line.add_point(start_pos)

	var last_pos = start_pos
	for pos in target_positions:
		add_jagged_segments(last_pos, pos)
		last_pos = pos

	lightning_line.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(lightning_line, "modulate:a", 0.0, 0.25).set_trans(Tween.TRANS_BOUNCE)

func add_jagged_segments(start: Vector2, end: Vector2):
	var segments = 3
	var direction = (end - start).normalized()
	var distance = start.distance_to(end)
	var step_length = distance / segments

	for i in range(1, segments):
		var base_point = start + direction * (step_length * i)
		var perpendicular = Vector2(-direction.y, direction.x)
		var random_offset = perpendicular * randf_range(-12.0, 12.0)
		lightning_line.add_point(base_point + random_offset)

	lightning_line.add_point(end)

# --- UPGRADES ---
func get_upgrade_info(next_level: int) -> Dictionary:
	match next_level:
		2:
			return {
				"desc": "[color=green]+1 Max Bounces[/color]\nHits an extra target.",
				"rarity": "Common"
			}
		3:
			return {"desc": "[color=green]+8 Base Damage[/color]", "rarity": "Rare"}
		4:
			return {
				"desc": "[color=green]+20% Area[/color]\nJumps further.", "rarity": "Common"
			}
		5:
			return {
				"desc": "[color=green]+2 Max Bounces[/color]\n[color=orange]Zaps slightly stun enemies![/color]",
				"rarity": "Legendary"
			}
	return {"desc": "MAX", "rarity": "Common"}

func _apply_stats_for_current_level():
	match level:
		2:
			max_bounces += 1
		3:
			base_damage += 8.0
		4:
			base_area += 0.20
		5:
			max_bounces += 2
			# Stun-Logik ist oben in attack() eingebaut
