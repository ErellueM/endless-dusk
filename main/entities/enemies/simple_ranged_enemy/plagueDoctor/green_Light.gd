extends PointLight2D

@export var base_energy: float = 1.0
@export var pulse_amount: float = 0.3

var time_passed: float = 0.0
var pulse_speed: float = 5.0


func _ready():
	time_passed = randf_range(0.0, 100.0)
	pulse_speed = randf_range(4.0, 6.0)
	base_energy = base_energy * randf_range(0.8, 1.2)


func _process(delta):
	time_passed += delta
	energy = base_energy + sin(time_passed * pulse_speed) * pulse_amount
