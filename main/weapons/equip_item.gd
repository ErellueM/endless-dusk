extends Node2D
class_name EquipItem

@export var fire_rate : float = 0.5
var last_fired_time : float
var aim_angle : float
func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	rotation = aim_angle
	
func _try_use () -> bool:
	if Time.get_unix_time_from_system() - last_fired_time < fire_rate:
		return false
	
	last_fired_time = Time.get_unix_time_from_system()
	_use_weapon()
	return true
	

func _use_weapon () -> void:
	pass

func set_aim_angle(angle_dir: Vector2):
	aim_angle = angle_dir.angle()
