extends Area2D

var damage: float = 0.0
var velocity: Vector2 = Vector2.ZERO
var weapon_ref: Node2D = null
var pierced: int = 0
var hit_targets: Array = [] # Verhindert, dass derselbe Gegner pro Frame 5x getroffen wird

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
	if target in hit_targets:
		return
		
	if (target.is_in_group("Enemygroup") or target.is_in_group("Props")) and target.has_method("take_damage"):
		hit_targets.append(target)
		
		# Schaden zufügen
		var actual_damage = target.take_damage(damage, true)
		if weapon_ref and is_instance_valid(weapon_ref):
			weapon_ref.add_damage_stat(actual_damage)
			
		# Piercing-Zähler erhöhen NACHDEM Schaden gemacht wurde
		pierced += 1
		
		# Prüfen, ob der Pfeil sein Limit erreicht hat
		# weapon_ref.piercing_count = 0 heißt: Pfeil verschwindet nach 1 Treffer (pierced = 1)
		if weapon_ref and pierced > weapon_ref.piercing_count:
			queue_free()
