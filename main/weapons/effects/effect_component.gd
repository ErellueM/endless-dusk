class_name EffectComponent
extends Node

@export var effects: Array[Effect]

func apply(target, stats):
	for effect in effects:
		effect.apply_to(target, stats)
		
