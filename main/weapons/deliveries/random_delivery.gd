extends Delivery

func deliver(stats, effects):
	pass

func get_all_enemies()-> Array[Node]:
	return get_tree().get_nodes_in_group("Enemygroup")

func get_all_onscreen_enemies()-> Array[Node]:
	return get_all_enemies().filter(is_valid_target)

func is_valid_target(enemy)-> bool:
	if enemy.get("is_dead"): return false
	
	var screen_position = enemy.get_global_transform_with_canvas().origin
	var viewport_rect = get_viewport_rect()
	
	return viewport.has_point(screen_position)
