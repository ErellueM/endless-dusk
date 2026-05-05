extends Area2D

var damage: float = 0.0
var velocity: Vector2 = Vector2.ZERO
var weapon_ref: Node2D = null

var hit_targets: Array = [] 

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
	var unique_id = str(target.get_instance_id()) + "_" + str(target.get("spawn_generation"))

	if unique_id in hit_targets:
		return 
		
	if (target.is_in_group("Enemygroup") or target.is_in_group("Props")) and target.has_method("take_damage"):
		hit_targets.append(unique_id)
		
		var actual_damage = target.take_damage(damage, true)

		if weapon_ref and is_instance_valid(weapon_ref):
			weapon_ref.add_damage_stat(actual_damage)
			
		if target.has_method("add_status_effect"):
			var burn_tick_damage = damage * 0.3
			target.add_status_effect(BurnEffect.new(3.0, burn_tick_damage, 1.0, weapon_ref))
