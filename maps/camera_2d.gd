extends Camera2D

@export var smoothing_enabled: bool = true
@export_range(0.0, 10.0, 0.1) var smoothing_speed: float = 5.0

var target_node: Node2D

# --- NEU: SHAKE VARIABLEN ---
var shake_timer: float = 0.0
var shake_intensity: float = 0.0

func _ready():
	make_current()
	# WICHTIG: Damit der Glockenschläger die Kamera findet!
	add_to_group("camera") 

func _process(delta: float) -> void:
	# --- 1. KAMERA FOLGT DEM SPIELER ---
	if target_node:
		if smoothing_enabled:
			# Kamera folgt weich dem Player
			global_position = global_position.lerp(target_node.global_position, delta * smoothing_speed)
		else:
			# Kamera folgt exakt (ohne Glättung)
			global_position = target_node.global_position

	# --- 2. SCREENSHAKE LOGIK ---
	if shake_timer > 0:
		shake_timer -= delta
		# Wir wackeln nur mit dem Offset, nicht mit der Position!
		var random_x = randf_range(-shake_intensity, shake_intensity)
		var random_y = randf_range(-shake_intensity, shake_intensity)
		offset = Vector2(random_x, random_y)
		
		# (Optional) Lässt das Wackeln sanft ausklingen, statt abrupt aufzuhören
		shake_intensity = lerp(shake_intensity, 0.0, delta * 5.0)
	else:
		offset = Vector2.ZERO # Wieder exakt mittig ausrichten, wenn vorbei

# --- 3. DIE FUNKTION, DIE VOM GEGNER AUFGERUFEN WIRD ---
func shake(duration: float, intensity: float):
	shake_timer = duration
	shake_intensity = intensity
