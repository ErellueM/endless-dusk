extends Node2D

@export var speed = 200
@onready var anim = $AnimatedSprite2D  # dein AnimatedSprite2D Node

func _process(delta):
	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	# Bewegung
	position += direction.normalized() * speed * delta

	# Animationen
	if direction.length() > 0:
		anim.play("walk")
		# Sprite nach links/rechts spiegeln
		if direction.x != 0:
			anim.flip_h = direction.x < 0
	else:
		anim.play("idle")
