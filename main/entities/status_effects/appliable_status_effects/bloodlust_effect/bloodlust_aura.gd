extends Node2D

@export var color: Color = Color(0.9, 0.05, 0.05, 0.4)  # Alpha auf 0.4 (viel transparenter)
@export var rotation_speed: float = 1.2  # Etwas langsamer für einen "schwereren" Look

var radius: float = 15.0  # Standardwert


func _ready():
	z_index = -1
	scale = Vector2.ZERO

	# AUTOMATISCHE GRÖSSENANPASSUNG:
	# Wir schauen uns den Vater (den Gegner) an und versuchen die Größe zu schätzen
	var parent = get_parent()
	if parent is CharacterBody2D:
		# Wir suchen nach dem Sprite des Gegners
		var sprite = parent.get_node_or_null("AnimatedSprite2D")
		if not sprite:
			sprite = parent.get_node_or_null("Sprite2D")

		if sprite:
			# Wir nehmen die Breite des aktuellen Bildes als Basis für den Radius
			var sprite_width = 16.0  # Fallback
			if sprite is AnimatedSprite2D and sprite.sprite_frames:
				var tex = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
				if tex:
					sprite_width = tex.get_size().x
			elif sprite is Sprite2D and sprite.texture:
				sprite_width = sprite.texture.get_size().x

			# Radius ist die halbe Breite + ein kleiner Puffer (2-4 Pixel)
			radius = (sprite_width * 0.5) + 2.0

	# Erscheinen-Animation
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(
		Tween.EASE_OUT
	)


func _process(delta):
	rotation += rotation_speed * delta
	queue_redraw()


func _draw():
	# 1. Den äußeren Kreis zeichnen (Linienstärke etwas dünner: 1.0)
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, color, 1.0, true)

	# 2. Das Pentagramm
	# Wir berechnen die 5 Punkte des Sterns basierend auf dem dynamischen Radius
	var points = []
	for i in range(5):
		var angle = i * (TAU / 5) - PI / 2
		points.append(Vector2(cos(angle), sin(angle)) * radius)

	# Die Linien des Sterns verbinden (0->2, 2->4, 4->1, 1->3, 3->0)
	var connections = [0, 2, 4, 1, 3, 0]
	for i in range(5):
		var p1 = points[connections[i]]
		var p2 = points[connections[i + 1]]
		draw_line(p1, p2, color, 0.8, true)


func shrink_and_free():
	var tween = create_tween()
	# Beim Verschwinden dreht er sich schneller (wie ein Abfluss)
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.4).set_trans(Tween.TRANS_SINE).set_ease(
		Tween.EASE_IN
	)
	tween.tween_property(self, "rotation_speed", rotation_speed * 4, 0.4)

	tween.set_parallel(false)
	tween.tween_callback(queue_free)
