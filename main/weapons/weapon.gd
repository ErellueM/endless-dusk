extends Node

@export var damage = 10
@export var fire_rate = 1.0  # shots per second

func attack():
	# Override this with weapon-specific attack logic
	print("Attack with damage: %d" % damage)
