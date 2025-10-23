extends Camera2D

@export var smoothing_enabled: bool = true
@export_range(0.0, 10.0, 0.1) var smoothing_speed: float = 5.0

var target_node: Node2D

func _ready():
	make_current()

func _process(delta: float) -> void:
	if not target_node:
		return

	if smoothing_enabled:
		# Kamera folgt weich dem Player
		global_position = global_position.lerp(target_node.global_position, delta * smoothing_speed)
	else:
		# Kamera folgt exakt (ohne Glättung)
		global_position = target_node.global_position
