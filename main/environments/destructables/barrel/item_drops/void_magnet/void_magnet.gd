extends BasePickup


func _apply_effect(player: Node2D):
	for gem in XpPool.active_gems:
		if is_instance_valid(gem) and not gem.is_flying:
			if gem.has_method("fly_to_player"):
				gem.fly_to_player(player)
