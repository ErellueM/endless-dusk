extends Area2D

var damage: float = 0.0
var velocity: Vector2 = Vector2.ZERO
var weapon_ref: Node2D = null
var pierced: int = 0

func _ready():
	top_level = true 
	
	body_entered.connect(_on_hit)
	area_entered.connect(_on_hit)

	if has_node("VisibleOnScreenNotifier2D"):
		$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
	else:
		await get_tree().create_timer(15.0).timeout
		queue_free()

func _physics_process(delta):
	position += velocity * delta
	rotation = velocity.angle()

func _on_hit(target: Node2D):
	
	if pierced >= weapon_ref.piercing_count:
		queue_free()
		
	if (target.is_in_group("Enemygroup") or target.is_in_group("Props")) and target.has_method("take_damage"):
		var actual_damage = target.take_damage(damage, true)
		if weapon_ref and is_instance_valid(weapon_ref):
			weapon_ref.add_damage_stat(actual_damage)
		pierced += 1
