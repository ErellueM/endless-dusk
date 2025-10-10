extends Node2D

@onready var flame = $CandleFrames       # passe das an, wenn dein Node anders heißt
@onready var light = $Flame            # ggf. anpassen, z. B. $Light oder $CandleLight

var t := 0.0

func _ready():
	# Animation starten
	if flame:
		flame.play()
	randomize()

func _process(delta):
	t += delta

	# --- Flackernde Lichtintensität ---
	# Kombination aus Sinus und leichtem Zufall für natürliches „Atem“-Flackern
	if light:
		var base_energy = 1.2
		var sin_wave = 0.1 * sin(t * 8.0)     # sanftes rhythmisches Schwanken
		var random_flick = randf() * 0.1      # unregelmäßige Schwankung
		light.energy = base_energy + sin_wave + random_flick

	# --- Optional: Flamme leicht skalieren ---
	if flame:
		var flick_scale = 1.0 + 0.05 * sin(t * 10.0) + randf() * 0.03
		flame.scale = Vector2(1, flick_scale)
