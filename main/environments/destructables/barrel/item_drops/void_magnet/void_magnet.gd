extends BasePickup

func _apply_effect(player: Node2D):
	var all_gems = get_tree().get_nodes_in_group("XPGem")
	for gem in all_gems:
		if gem.has_method("fly_to_player"):
			gem.fly_to_player(player)
