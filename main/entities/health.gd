extends Node

@export var max_health = 100
var current_health = max_health

signal died  # Signal for when health reaches zero

func _ready():
	current_health = max_health

func take_damage(amount):
	current_health -= amount
	if current_health <= 0:
		current_health = 0
		emit_signal("died")
