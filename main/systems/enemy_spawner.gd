extends Node


func spawn_enemy_around_player(
	player: Node2D, enemy_scene: PackedScene, min_distance: float, max_distance: float
) -> void:
	var angle := randf() * TAU
	var distance := randf_range(min_distance, max_distance)
	var offset := Vector2(cos(angle), sin(angle)) * distance

	var enemy := enemy_scene.instantiate() as Node2D
	enemy.global_position = player.global_position + offset
	get_tree().current_scene.add_child(enemy)


func spawn_enemy_group(
	player: Node2D, enemy_scene: PackedScene, min_distance: float, max_distance: float, count: int
) -> void:
	var angle := randf() * TAU
	var distance := randf_range(min_distance, max_distance)
	var group_center_offset := Vector2(cos(angle), sin(angle)) * distance
	var group_center := player.global_position + group_center_offset

	for i in range(count):
		var random_radius = randf_range(0, 20)
		var local_angle = randf() * TAU
		var spawn_pos = group_center + Vector2(cos(local_angle), sin(local_angle)) * random_radius

		var enemy := enemy_scene.instantiate() as Node2D
		enemy.global_position = spawn_pos
		get_tree().current_scene.add_child(enemy)
