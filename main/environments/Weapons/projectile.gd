extends Node2D


var velocity = Vector2.ZERO
var speed = 400

func _physics_process(delta):
	position += velocity * delta

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemygroup"):
		print("Getroffen: ", body.name)
		queue_free()
