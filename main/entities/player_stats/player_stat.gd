extends Resource
class_name PlayerStat

@export var default_value: float
var value: float

func _init() -> void:
	value = default_value

func get_icon():
	pass
