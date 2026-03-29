class_name DamageBuff
extends Modifier

@export var multiplier := 1.5

func apply(stats):
	stats.damage *= multiplier
