extends Node2D

@export var color: Color = Color(0.9, 0.05, 0.05, 0.4)
@export var rotation_speed: float = 1.2

var radius: float = 15.0

func _ready():
	z_index = -1
	scale = Vector2.ZERO
	_setup_radius()
	queue_redraw()
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _setup_radius():
	var parent = get_parent()
	if parent:
		var sprite = parent.get_node_or_null("AnimatedSprite2D")
		if not sprite:
			sprite = parent.get_node_or_null("Sprite2D")

		if sprite:
			var sprite_width = 16.0
			if sprite is AnimatedSprite2D and sprite.sprite_frames:
				var tex = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
				if tex: sprite_width = tex.get_size().x
			elif sprite is Sprite2D and sprite.texture:
				sprite_width = sprite.texture.get_size().x

			radius = (sprite_width * 0.5) + 2.0

func _process(delta):
	rotation += rotation_speed * delta

func _draw():
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, color, 1.0, true)
	var points = []
	for i in range(5):
		var angle = i * (TAU / 5) - PI / 2
		points.append(Vector2(cos(angle), sin(angle)) * radius)

	var connections = [0, 2, 4, 1, 3, 0]
	for i in range(5):
		var p1 = points[connections[i]]
		var p2 = points[connections[i + 1]]
		draw_line(p1, p2, color, 0.8, true)

func shrink_and_free():
	set_process(false)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	# Wir animieren die Rotation im Tween für den Effekt
	tween.tween_property(self, "rotation", rotation + PI, 0.4)
	tween.chain().tween_callback(queue_free)
