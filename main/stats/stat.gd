extends Resource
class_name Stat

@export var default_value: float
@export var icon: PackedScene
var value: float

func _init() -> void:
	value = default_value
