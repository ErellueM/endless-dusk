extends CharacterBody2D

@export var speed: float = 100.0
var player: Node2D

func _physics_process(_delta):

	player = get_tree().get_first_node_in_group("player")
	if player == null:
		return  # Spieler noch nicht vorhanden

	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
