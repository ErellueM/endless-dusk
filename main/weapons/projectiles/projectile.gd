extends CharacterBody2D

var damage
var effects

func _on_hit(target):
	target.take_damage(damage)

	if effects:
		effects.apply(target)
