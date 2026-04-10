class_name BasePickup extends Area2D

var target_player: Node2D = null
var is_flying: bool = false
var fly_speed: float = 1.0


func _ready():
	body_entered.connect(_on_body_entered)


func _process(delta):
	if is_flying and target_player:
		var direction = (target_player.global_position - global_position).normalized()
		global_position += direction * fly_speed * delta


func fly_to_player(player_node: Node2D):
	target_player = player_node
	is_flying = true
	var tween = create_tween()
	tween.tween_property(self, "fly_speed", 1200.0, 0.5)


func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		_apply_effect(body)
		queue_free()


func _apply_effect(_player: Node2D):
	pass
