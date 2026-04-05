extends Camera2D

@export var smoothing_enabled: bool = true
@export_range(0.0, 10.0, 0.1) var smoothing_speed: float = 5.0

var target_node: Node2D

var shake_timer: float = 0.0
var shake_intensity: float = 0.0

func _ready():
	make_current()
	add_to_group("camera") 

func _process(delta: float) -> void:
	if target_node:
		if smoothing_enabled:
			global_position = global_position.lerp(target_node.global_position, delta * smoothing_speed)
		else:
			global_position = target_node.global_position

		if shake_timer > 0:
			shake_timer -= delta
			var random_x = randf_range(-shake_intensity, shake_intensity)
			var random_y = randf_range(-shake_intensity, shake_intensity)
			offset = Vector2(random_x, random_y)

			shake_intensity = lerp(shake_intensity, 0.0, delta * 5.0)
		else:
			offset = Vector2.ZERO

# --- 3. DIE FUNKTION, DIE VOM GEGNER AUFGERUFEN WIRD ---
func shake(duration: float, intensity: float):
	if  not SettingsManager.enable_screenshake: return
	shake_timer = duration
	shake_intensity = intensity
