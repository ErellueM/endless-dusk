extends Node2D

var health

func _ready():
	health = $Health  # Health is a child node
	health.connect("died", Callable(self, "_on_death"))

func _on_death():
	queue_free()
