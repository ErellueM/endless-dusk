extends Area2D
class_name BaseAreaEnemy

@export var enemy_name: String = "Monster"
@export var is_miniboss: bool = false
@export var max_health: float = 50.0
@export var speed: float = 100.0
@export var damage: float = 10.0
@export var xp_reward: float = 1.0
@export var damage_number_scene: PackedScene = preload("res://main/ui/ingameUI/damage_number.tscn")
@export var chest_scene: PackedScene

@export_group("Status Immunities")
@export var immune_to_all_status: bool = false
@export var status_immunities: Array[String] = []

var player: Node2D
var is_dead: bool = false
var can_attack: bool = true

# AREA2D FIX: Wir müssen velocity selbst definieren!
var velocity: Vector2 = Vector2.ZERO 

@onready var health = $Health
@onready var anim = $AnimatedSprite2D
@onready var status_manager = $StatusManager

var is_flashing: bool = false

var base_max_health: float
var base_damage: float
var base_scale: Vector2 = Vector2.ONE

func _ready():
	add_to_group("Enemygroup")
	player = get_tree().get_first_node_in_group("player")
	# Leichte Speed-Variation
	speed = speed * randf_range(0.8, 1.2)
	base_max_health = max_health
	base_damage = damage
	base_scale = scale

	if health:
		health.max_health = max_health
		health.current_health = max_health
		health.died.connect(_on_death)

	if status_manager:
		status_manager.apply_tick_damage.connect(_on_tick_damage)


func _physics_process(_delta):
	if is_dead:
		return

	# FARBE VOM MANAGER HOLEN
	var c_mod = status_manager.color_mod if status_manager else Color(1, 1, 1)
	if not is_flashing and is_instance_valid(anim):
		anim.modulate = c_mod

	# --- BEWEGUNG ---
	if player:
		process_movement(_delta)

	# --- ANGRIFF ---
	if can_attack:
		# AREA2D FIX: Wir rufen es direkt auf uns selbst auf, keine extra Node nötig!
		var overlapping_bodies = get_overlapping_bodies()
		for body in overlapping_bodies:
			if body.is_in_group("player") and body.has_method("take_damage_typed"):
				var d_mult = status_manager.dmg_dealt_mult if status_manager else 1.0
				body.take_damage_typed(damage * d_mult)
				start_attack_cooldown()
				break


# --- FUNKTION FÜR DIE BEWEGUNG ---
func process_movement(_delta: float):
	var direction = (player.global_position - global_position).normalized()
	var s_mult = status_manager.speed_mult if status_manager else 1.0
	velocity = direction * (speed * s_mult)
	
	# AREA2D FIX: Wir rechnen die Position extrem performant selbst aus!
	global_position += velocity * _delta

	if velocity.x != 0:
		anim.flip_h = velocity.x < 0
		if anim.has_animation("default"):
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


func take_damage(amount: float, show_number: bool = true) -> float:
	return take_damage_typed(amount, false, Color(1, 1, 0), show_number)


func take_damage_typed(
	amount: float, is_dot: bool = false, dmg_color: Color = Color(1, 1, 0), show_number: bool = true
) -> float:
	if is_dead:
		return 0.0

	var t_mult = status_manager.dmg_taken_mult if status_manager else 1.0
	var display_damage = amount * t_mult
	var actual_damage = display_damage

	if health and health.get("current_health") != null:
		if actual_damage > health.current_health:
			actual_damage = health.current_health
	else:
		if actual_damage > max_health:
			actual_damage = max_health

	actual_damage = max(0.0, actual_damage)

	if show_number and SettingsManager.show_damage_numbers and display_damage > 0:
		var offset = Vector2(-20, -10) + Vector2(randf_range(-5, 5), randf_range(-5, 5))
		DamagePool.spawn_number(global_position + offset, display_damage, is_dot, dmg_color)

	if health and amount > 0:
		health.take_damage(display_damage)

	if not is_dot:
		_flash_hit()

	return actual_damage

func add_status_effect(effect: StatusEffect):
	if status_manager:
		status_manager.add_effect(effect)

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
	if is_miniboss:
		queue_free()
	else:
		EnemyPool.return_enemy(self)


# --- AUFWACHEN (Wird vom WaveManager gerufen) ---
func revive(new_pos: Vector2, difficulty_multiplier: float):
	is_dead = false
	$CollisionShape2D.set_deferred("disabled", false)
	
	scale = base_scale 
	modulate.a = 1.0

	# SKALIERUNG NUR VON BASISWERTEN
	max_health = base_max_health * difficulty_multiplier
	damage = base_damage * difficulty_multiplier
	
	can_attack = true
	is_flashing = false

	if health:
		health.max_health = max_health
		health.current_health = max_health

	if status_manager:
		status_manager.effects.clear()
		status_manager.speed_mult = 1.0
		status_manager.dmg_taken_mult = 1.0
		status_manager.dmg_dealt_mult = 1.0
		status_manager.color_mod = Color(1, 1, 1)

	global_position = new_pos
	force_update_transform()
	visible = true
	set_process(true)
	set_physics_process(true)


func drop_soul():
	if is_miniboss and chest_scene:
		var chest = chest_scene.instantiate()
		get_tree().current_scene.call_deferred("add_child", chest)
		chest.set_deferred("global_position", global_position)
	elif xp_reward > 0:
		XpPool.spawn_gem(global_position, xp_reward)
