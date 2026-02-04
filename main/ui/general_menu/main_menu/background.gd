extends Node2D

# Hol die Kamera (Kurzschreibweise ist sauberer)
@onready var camera = $"../Camera2D"

# Wie weit darf die Kamera maximal auslenken? (in Pixeln)
@export var parallax_strength = 15.0 

func _process(delta):
	if not camera: return

	# 1. Daten holen
	var viewport_rect = get_viewport_rect()
	var center = viewport_rect.size / 2.0
	var mouse_pos = get_viewport().get_mouse_position() # Besser als global für UI
	
	# 2. Berechnung: Wie weit ist die Maus von der Mitte weg? (-1 bis +1)
	# Wir nutzen clamp, damit es am Rand nicht "überschnappt"
	var dist_x = clamp((mouse_pos.x - center.x) / center.x, -1.0, 1.0)
	var dist_y = clamp((mouse_pos.y - center.y) / center.y, -1.0, 1.0)
	
	# 3. Das Ziel berechnen (Wo soll die Kamera hin?)
	# Wir addieren den Versatz zur Bildschirmmitte
	var target_pos = center + Vector2(dist_x, dist_y) * parallax_strength
	
	# 4. Position setzen (KEIN LERP HIER!)
	# Da wir "Position Smoothing" in der Kamera aktiviert haben, 
	# gleitet sie jetzt automatisch butterweich zu diesem Punkt.
	camera.position = target_pos
