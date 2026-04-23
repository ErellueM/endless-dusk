extends Area2D

var damage: float = 0.0
var velocity: Vector2 = Vector2.ZERO
var weapon_ref: Node2D = null

var hit_targets: Array = [] 

func _ready():
	# Befreit den Feuerball von der Drehung/Bewegung des Spielers
	top_level = true 
	
	body_entered.connect(_on_hit)
	area_entered.connect(_on_hit)

	# NEU: Das Projektil löscht sich selbst, sobald es den Bildschirm verlässt!
	if has_node("VisibleOnScreenNotifier2D"):
		$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
	else:
		# Nur ein Sicherheits-Fallback, falls du vergisst, die Node im Editor hinzuzufügen
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

		# Der Waffe den Schaden melden
		if weapon_ref and is_instance_valid(weapon_ref):
			weapon_ref.add_damage_stat(actual_damage)
			
		# Burn-Effekt anwenden
		if target.has_method("add_status_effect"):
			target.add_status_effect(BurnEffect.new(2.0, 1.0, 0.25, weapon_ref))
