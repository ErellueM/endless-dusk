extends CharacterBody2D
class_name BaseEnemy 

@export var enemy_name: String = "Monster"
@export var speed: float = 100.0
@export var damage: float = 10.0
@export var xp_gem_scene: PackedScene = preload("res://main/entities/xp/xp.tscn")
@export var xp_reward: float = 1.0 
@export var damage_number_scene: PackedScene = preload("res://main/ui/ingameUI/damage_number.tscn")

@export_group("Status Immunities")
@export var immune_to_all_status: bool = false
@export var status_immunities: Array[String] = []

var player: Node2D
var is_dead: bool = false        
var can_attack: bool = true      

@onready var health = $Health
@onready var anim = $AnimatedSprite2D
@onready var attack_area = $AttackArea
@onready var status_manager = $StatusManager 

var is_flashing: bool = false

func _ready():
	add_to_group("Enemygroup")
	player = get_tree().get_first_node_in_group("player")
	# Leichte Speed-Variation
	speed = speed * randf_range(0.8, 1.2)
	
	if health:
		health.died.connect(_on_death)
		
	if status_manager:
		status_manager.apply_tick_damage.connect(_on_tick_damage)

func _physics_process(_delta):
	if is_dead: return 
	
	# FARBE VOM MANAGER HOLEN
	var c_mod = status_manager.color_mod if status_manager else Color(1, 1, 1)
	if not is_flashing and is_instance_valid(anim):
		anim.modulate = c_mod
	
	# --- BEWEGUNG (Ausgelagert in eigene Funktion) ---
	if player:
		process_movement(_delta)
	
	# ANGRIFF (Damage mal Manager-Damage-Dealt)
	if can_attack:
		var overlapping_bodies = attack_area.get_overlapping_bodies()
		for body in overlapping_bodies:
			if body.is_in_group("player") and body.has_method("take_damage_typed"):
				var d_mult = status_manager.dmg_dealt_mult if status_manager else 1.0
				body.take_damage_typed(damage * d_mult)
				start_attack_cooldown()
				break

# --- NEUE FUNKTION FÜR DIE BEWEGUNG ---
# Diese Funktion kann von anderen Gegnern überschrieben werden!
func process_movement(_delta: float):
	var direction = (player.global_position - global_position).normalized()
	var s_mult = status_manager.speed_mult if status_manager else 1.0
	velocity = direction * (speed * s_mult)
	move_and_slide()
	
	if velocity.x != 0:
		anim.flip_h = velocity.x < 0
		anim.play("default")

func start_attack_cooldown():
	can_attack = false
	await get_tree().create_timer(1.0).timeout 
	can_attack = true

func _on_tick_damage(amount: float, source: Node2D, color: Color):
	var t_mult = status_manager.dmg_taken_mult if status_manager else 1.0
	var final_dmg = amount * t_mult
	var true_damage_dealt = take_damage_typed(final_dmg, true, color)
	
	if source and is_instance_valid(source) and source.has_method("add_damage_stat"):
		source.add_damage_stat(true_damage_dealt)

func take_damage(amount: float) -> float:
	return take_damage_typed(amount, false, Color(1, 1, 0))

func take_damage_typed(amount: float, is_dot: bool = false, dmg_color: Color = Color(1, 1, 0)) -> float:
	if is_dead: return 0.0
	
	var t_mult = status_manager.dmg_taken_mult if status_manager else 1.0
	var display_damage = amount * t_mult 
	var actual_damage = display_damage
	if health and actual_damage > health.current_health:
		actual_damage = health.current_health
		
	actual_damage = max(0.0, actual_damage)
	
	if damage_number_scene and display_damage > 0:
		var dmg_num = damage_number_scene.instantiate()
		var offset = Vector2(38, -20)
		var random_offset = Vector2(randf_range(-5, 5), randf_range(-5, 5))
		dmg_num.global_position = global_position + random_offset + offset
		get_tree().current_scene.call_deferred("add_child", dmg_num)
		
		dmg_num.setup(display_damage, false, is_dot, dmg_color)
	
	if health and amount > 0:
		health.take_damage(display_damage)
	
	if not is_dot:
		_flash_hit()
			
	return actual_damage

func _flash_hit():
	is_flashing = true
	anim.modulate = Color(1, 0.1, 0.1)
	await get_tree().create_timer(0.2).timeout
	is_flashing = false

func _on_death():
	is_dead = true
	$CollisionShape2D.set_deferred("disabled", true) 
	Global.register_kill(enemy_name)
	drop_soul()
	queue_free()

func drop_soul():
	if xp_gem_scene != null:
		var gem = xp_gem_scene.instantiate()
		gem.xp_value = xp_reward
		var offset = Vector2(38, 0)
		gem.set_deferred("global_position", global_position + offset)
		get_tree().current_scene.call_deferred("add_child", gem)
