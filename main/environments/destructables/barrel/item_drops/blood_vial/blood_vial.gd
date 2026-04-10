extends BasePickup

@export var heal_amount: float = 20.0


func _apply_effect(player: Node2D):
	if player.has_method("heal"):
		player.heal(heal_amount)
