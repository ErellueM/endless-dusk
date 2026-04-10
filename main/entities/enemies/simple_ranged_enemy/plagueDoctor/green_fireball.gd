extends Area2D

@export var speed: float = 250.0
@export var damage: float = 15.0
var direction: Vector2 = Vector2.ZERO


func _ready():
	body_entered.connect(_on_body_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)


func _physics_process(delta):
	position += direction * speed * delta
	rotation = direction.angle()


func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
			var status_manager = body.get_node_or_null("StatusManager")
			if status_manager:
				status_manager.add_effect(PoisonEffect.new(3.0, 1.0, 1.0))
		queue_free()
