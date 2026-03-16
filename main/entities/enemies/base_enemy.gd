extends CharacterBody2D
class_name BaseEnemy 

@export var speed: float = 100.0
@export var damage: float = 10.0
@export var xp_gem_scene: PackedScene 
@export var damage_number_scene: PackedScene

var player: Node2D
var is_dead: bool = false       
var can_attack: bool = true     

@onready var health = $Health
@onready var anim = $AnimatedSprite2D


func _ready():
	add_to_group("Enemygroup")
	player = get_tree().get_first_node_in_group("player")
	speed = speed * randf_range(0.8, 1.2)
	
	if health:
		health.died.connect(_on_death)

@onready var attack_area = $AttackArea

func _physics_process(_delta):
	if player == null or is_dead:
		return 
	
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	
	if velocity.x != 0:
		anim.flip_h = velocity.x < 0
		anim.play("default")
	
	
	if can_attack:
		var overlapping_bodies = attack_area.get_overlapping_bodies()
		for body in overlapping_bodies:
			if body.is_in_group("player") and body.has_method("take_damage"):
				body.take_damage(damage)
				start_attack_cooldown()
				break
	
	if can_attack:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider.is_in_group("player") and collider.has_method("take_damage"):
				collider.take_damage(damage)
				start_attack_cooldown()

func start_attack_cooldown():
	can_attack = false
	await get_tree().create_timer(1.0).timeout 
	can_attack = true

func take_damage(amount: float):
	if is_dead: return
	
	if damage_number_scene:
		var dmg_num = damage_number_scene.instantiate()
		var offset = Vector2(+38, -20)
		var random_offset = Vector2(randf_range(-5, 5), randf_range(-5, 5))
		dmg_num.global_position = global_position + random_offset + offset
		get_tree().current_scene.call_deferred("add_child", dmg_num)
		dmg_num.setup(amount, false)
	
	if health:
		health.take_damage(amount)
		
	anim.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	anim.modulate = Color(1, 1, 1)

func _on_death():
	is_dead = true
	
	$CollisionShape2D.set_deferred("disabled", true) 
	drop_soul()
	#anim.play("death")
	#await anim.animation_finished 
	queue_free() 

func drop_soul():
	if xp_gem_scene != null:
		var gem = xp_gem_scene.instantiate()
		var offset = Vector2(+38,0)
		gem.set_deferred("global_position", global_position + offset)
		get_tree().current_scene.call_deferred("add_child", gem)
