extends Node

var max_health
var current_health = max_health

signal died  # Signal for when health reaches zero
signal health_changed(current_health, max_health)

func _ready():
	current_health = max_health


func take_damage(amount):
	current_health -= amount
	if current_health <= 0:
		current_health = 0
		emit_signal("died")
	health_changed.emit(current_health, max_health)
