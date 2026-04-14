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

# --- NEU: Status Manager Objekt (Keine Node!) ---
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
	
	# Manager instanziieren
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

	# Status-Logik verarbeiten
	status_manager.process_logic(delta)

	# Bewegung mit Speed-Multiplikator vom Status Manager
	var move_amount = (speed * status_manager.speed_mult) * delta
	global_position = global_position.move_toward(player.global_position, move_amount)

	var dir_x = player.global_position.x - global_position.x
	if abs(dir_x) > 1.0:
		sprite.flip_h = dir_x < 0
	
	# Farben aktualisieren
	_update_visual_state()

func _update_visual_state():
	if is_flashing: return
	
	# Wir nutzen die Farbe direkt vom Status Manager
	sprite.modulate = base_color * status_manager.color_mod

# Schnittstelle für Waffen
func add_status_effect(effect):
	if status_manager:
		status_manager.add_effect(effect)

func take_damage(amount: float, show_number: bool = true) -> float:
	if is_dead: return 0.0

	# Schaden mit dmg_taken_mult vom Status Manager verrechnen
	var final_amount = amount * status_manager.dmg_taken_mult
	current_health -= final_amount

	if show_number and SettingsManager.show_damage_numbers and final_amount > 0:
		var offset = Vector2(randf_range(-10, 10), randf_range(-20, -10))
		DamagePool.spawn_number(global_position + offset, final_amount, false, Color(1, 1, 0))

	is_flashing = true
	sprite.modulate = Color(10, 10, 10)
	var flash_tween = create_tween()
	flash_tween.tween_interval(0.1)
	flash_tween.tween_callback(func(): 
		is_flashing = false
		_update_visual_state()
	)

	if current_health <= 0:
		die()
	return final_amount

# Hilfsmethode für das Pooling
func revive(new_pos: Vector2, difficulty_multiplier: float):
	is_dead = false
	scale = base_scale
	modulate.a = 1.0
	
	max_health = base_max_health * difficulty_multiplier
	current_health = max_health
	damage = base_damage * difficulty_multiplier

	# Status Effekte beim Revive löschen!
	if status_manager:
		status_manager.effects.clear()

	global_position = new_pos
	force_update_transform()
	visible = true
	set_process(true)
	set_physics_process(true)
	_update_visual_state()

func die():
	if is_dead: return
	is_dead = true
	Global.register_kill(enemy_name)
	if xp_reward > 0:
		XpPool.spawn_gem(global_position, xp_reward)
	EnemyPool.return_enemy(self)

func _on_body_entered(body: Node2D):
	if is_dead: return
	if body.is_in_group("player") and body.has_method("take_damage_typed"):
		body.take_damage_typed(damage)
