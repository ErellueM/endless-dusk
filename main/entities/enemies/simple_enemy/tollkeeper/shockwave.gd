extends Node2D
class_name DustShockwave

var max_radius: float = 200.0
var duration: float = 0.6
var dust_color: Color = Color(0.75, 0.7, 0.65, 0.8) # Grau-Brauner Staub

# Diese Werte werden vom Tween animiert!
var current_radius: float = 10.0
var current_thickness: float = 2.0

func _ready():
	# z_index = -1 # <-- Nur einkommentieren, wenn dein Fußboden z_index < -1 hat!
	
	var tween = create_tween()
	tween.set_parallel(true) 
	
	# Radius explodiert nach außen 
	tween.tween_property(self, "current_radius", max_radius, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Staub wird dick, dann dünn
	tween.tween_property(self, "current_thickness", 30.0, duration * 0.2)
	tween.tween_property(self, "current_thickness", 0.0, duration * 0.8).set_delay(duration * 0.2)
	
	# Welle verblasst sanft
	var transparent_color = dust_color
	transparent_color.a = 0.0
	tween.tween_property(self, "modulate", transparent_color, duration).set_ease(Tween.EASE_IN)
	
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.chain().tween_callback(queue_free)

func _process(_delta):
	queue_redraw()

func _draw():
	# draw_arc braucht 8 Parameter in Godot 4.
	draw_arc(Vector2.ZERO, current_radius, 0, TAU, 64, dust_color, current_thickness, true)
