extends Node2D

@onready var flame = $CandleFrames   # dein AnimatedSprite2D
@onready var light = $Flame          # dein PointLight2D

var t := 0.0

func _ready():
	if flame:
		flame.play()   # startet die Flammenanimation
	randomize()

func _process(delta):
	t += delta

	# --- Nur das Licht flackert ---
	if light:
		var base_energy = 1.2
		var sin_wave = 0.15 * sin(t * 8.0)   # sanftes rhythmisches Schwanken
		var random_flick = randf() * 0.05    # leichte Unregelmäßigkeit
		light.energy = base_energy + sin_wave + random_flick
