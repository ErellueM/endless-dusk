extends Delivery
class_name HitboxDelivery

@export var hitbox_scene: PackedScene
var hitbox

func _ready() -> void:
	hitbox = hitbox_scene.instantiate()

func deliver(stats, effects):
	add_child(hitbox)
