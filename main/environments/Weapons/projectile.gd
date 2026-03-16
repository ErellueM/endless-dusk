extends Node2D

var start_position: Vector2
var velocity = Vector2.ZERO
var speed = 150
@export var damage: float = 50.0
@export var max_distance: float = 400.0

func _ready():
	start_position = global_position

func _physics_process(delta):
	position += velocity * delta
	if global_position.distance_to(start_position) > max_distance:
		queue_free()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemygroup"):
		print("Getroffen: ", body.name)
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
