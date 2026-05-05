extends Area2D
class_name DumbSwarmEnemy

@export_group("Base Stats")
@export var enemy_name: String = "Green Slime"
@export var max_health: float = 5.0
@export var speed: float = 60.0
@export var damage: float = 2.0
@export var xp_reward: float = 0.5

@export_group("Visuals")
@export var base_color: Color = Color(1, 1, 1)

@export_group("Status Immunities")
@export var immune_to_all_status: bool = false
@export var status_immunities: Array[String] = []

var current_health: float
var player: Node2D
var is_dead: bool = false

# --- DER POOL FIX ---
var spawn_generation: int = 0

var status_manager: StatusManagerLight

var base_max_health: float
var base_damage: float
var base_scale: Vector2 = Vector2.ONE
var is_flashing: bool = false

@onready var sprite = $AnimatedSprite2D

func _ready():
	add_to_group("Enemygroup")
	add_to_group("SwarmEnemies")
	player = get_tree().get_first_node_in_group("player")
	
	status_manager = StatusManagerLight.new(self)
	
	base_max_health = max_health
	base_damage = damage
	base_scale = scale
	current_health = max_health

	speed = speed * randf_range(0.9, 1.1)
	body_entered.connect(_on_body_entered)
	_update_visual_state()

func _physics_process(delta: float):
	if is_dead or not player:
		return

	status_manager.process_logic(delta)

	var move_amount = (speed * status_manager.speed_mult) * delta
	global_position = global_position.move_toward(player.global_position, move_amount)

	var dir_x = player.global_position.x - global_position.x
	if abs(dir_x) > 1.0:
		sprite.flip_h = dir_x < 0
	
	_update_visual_state()

func _update_visual_state():
	if is_flashing: return
	sprite.modulate = base_color * status_manager.color_mod

func add_status_effect(effect):
	if status_manager:
		status_manager.add_effect(effect)

# --- KOMPATIBILITÄT FÜR BURN-EFFEKTE (take_damage_typed) ---
func take_damage(amount: float, show_number: bool = true) -> float:
	return take_damage_typed(amount, false, Color(1, 1, 0), show_number)

func take_damage_typed(amount: float, is_dot: bool = false, dmg_color: Color = Color(1, 1, 0), show_number: bool = true) -> float:
	if is_dead: return 0.0
	
	var display_amount = amount * status_manager.dmg_taken_mult
	var actual_damage = display_amount
	
	if actual_damage > current_health:
		actual_damage = current_health
		
	actual_damage = max(0.0, actual_damage)
	current_health -= display_amount
	
	if show_number and SettingsManager.show_damage_numbers and display_amount > 0:
		var offset = Vector2(randf_range(-10, 10), randf_range(-20, -10))
		DamagePool.spawn_number(global_position + offset, display_amount, is_dot, dmg_color)
	
	if not is_dot:
		_flash_hit()

	if current_health <= 0:
		die()
		
	return actual_damage

# --- HIT FLASH FIX ---
func _flash_hit():
	is_flashing = true
	# DAS WAR DEIN WEIß-BUG! Du hattest hier Color(10, 10, 10) stehen!
	sprite.modulate = Color(1.0, 0.1, 0.1) # Jetzt wird es Rot!
	
	var tween = create_tween()
	var target_color = base_color * status_manager.color_mod
	tween.tween_property(sprite, "modulate", target_color, 0.15)
	tween.tween_callback(func(): 
		is_flashing = false
		_update_visual_state()
	)

# --- WIEDERBELEBUNG VOM WAVEMANAGER ---
func revive(new_pos: Vector2, difficulty_multiplier: float):
	spawn_generation += 1 # DER WICHTIGE POOL FIX!
	is_dead = false
	
	# PHYSIK SICHER RESETTEN
	var coll = get_node_or_null("CollisionShape2D")
	if coll: coll.set_deferred("disabled", false)
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	
	scale = base_scale
	modulate.a = 1.0
	
	max_health = base_max_health * difficulty_multiplier
	current_health = max_health
	damage = base_damage * difficulty_multiplier

	if status_manager:
		status_manager.effects.clear()
		status_manager.speed_mult = 1.0
		status_manager.dmg_taken_mult = 1.0
		status_manager.color_mod = Color(1, 1, 1)

	global_position = new_pos
	force_update_transform()
	visible = true
	set_process(true)
	set_physics_process(true)
	is_flashing = false
	_update_visual_state()

func die():
	if is_dead: return
	is_dead = true
	
	# PHYSIK AUSSCHALTEN, DAMIT DER POOL NICHT VERWIRRT WIRD
	var coll = get_node_or_null("CollisionShape2D")
	if coll: coll.set_deferred("disabled", true)
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	
	Global.register_kill(enemy_name)
	if xp_reward > 0:
		XpPool.spawn_gem(global_position, xp_reward)
		
	EnemyPool.return_enemy(self)

func _on_body_entered(body: Node2D):
	if is_dead: return
	if body.is_in_group("player") and body.has_method("take_damage_typed"):
		var d_mult = status_manager.dmg_dealt_mult if status_manager else 1.0
		body.take_damage_typed(damage * d_mult)
