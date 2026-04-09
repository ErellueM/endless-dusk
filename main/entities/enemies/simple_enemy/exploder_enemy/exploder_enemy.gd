extends BaseEnemy

@export var explosion_range: float = 60.0
@export var explosion_damage: float = 20.0
@export var explosion_radius: float = 80.0

var has_exploded: bool = false

func _ready():
	super._ready()
	print("Player ist: ", player)
	can_attack = false  # normaler Angriff aus

func _physics_process(delta):
	if is_dead or has_exploded:
		return
	
	# normale Bewegung vom BaseEnemy
	super._physics_process(delta)
	
	if player:
		var distance = global_position.distance_to(player.global_position)
		
		if distance <= explosion_range:
			explode()

func explode():
	has_exploded = true
	
	var bodies = get_tree().get_nodes_in_group("player")
	
	for body in bodies:
		if body.has_method("take_damage"):
			var dist = global_position.distance_to(body.global_position)
			
			if dist <= explosion_radius:
				body.take_damage(explosion_damage)
	
	queue_free()
