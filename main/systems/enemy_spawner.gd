extends Node

func spawn_enemy_around_player(
	player: Node2D,
	enemy_scene: PackedScene,
	min_distance: float,
	max_distance: float
) -> void:
	var angle := randf() * TAU
	var distance := randf_range(min_distance, max_distance)

	var offset := Vector2(cos(angle), sin(angle)) * distance

	var enemy := enemy_scene.instantiate() as Node2D
	enemy.global_position = player.global_position + offset

	get_tree().current_scene.add_child(enemy)
