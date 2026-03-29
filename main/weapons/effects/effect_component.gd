class_name EffectComponent
extends Node

@export var effects: Array[Resource]

func apply(target):
	for effect in effects:
		effect.apply_to(target)
