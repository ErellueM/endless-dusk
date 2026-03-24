extends CharacterBody2D

signal xp_changed(current, max_val)
signal health_changed(current, max_val)
signal leveled_up()

var level: int = 1
var current_xp: float = 0
var max_xp: float = 10.0

@export var damage_number_scene: PackedScene

@export_group("Movement")
@export var speed: float = 200.0

@export_group("Survival Stats")
@export var max_health: float = 100.0
@export var armor: float = 0.0          
@export var recovery: float = 0.0       

@export_group("Offensive Stats")
@export var might: float = 1.0          
@export var area: float = 1.0           
@export var cooldown_mult: float = 1.0  

@export_group("Utility Stats")
@export var magnet_mult: float = 1.0 
@export var growth: float = 1.0         
@export var luck: float = 1.0

@export_group("Status Immunities")
@export var immune_to_all_status: bool = false
@export var status_immunities: Array[String] = []

@onready var health_component = $Health
@onready var anim = $AnimatedSprite2D
@onready var magnet_shape = $MagnetArea/CollisionShape2D
@onready var status_manager = $StatusManager

var base_magnet_radius: float = 0.0
var pending_levelups: int = 0
var is_flashing: bool = false 

func _ready():
	if health_component:
		health_component.died.connect(die)
		
	if magnet_shape and magnet_shape.shape:
		base_magnet_radius = magnet_shape.shape.radius 
		update_magnet()
		$MagnetArea.area_entered.connect(_on_magnet_area_entered)
		
	if status_manager:
		status_manager.apply_tick_damage.connect(_on_tick_damage)

func _physics_process(delta):
	# FARBE VOM MANAGER HOLEN
	var c_mod = status_manager.color_mod if status_manager else Color(1, 1, 1)
	if not is_flashing and is_instance_valid(anim):
		anim.modulate = c_mod

	if health_component and recovery > 0:
		if health_component.current_health < health_component.max_health:
			health_component.current_health += recovery * delta
			health_component.current_health = min(health_component.current_health, health_component.max_health)
			health_changed.emit(health_component.current_health, health_component.max_health)

	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right"): direction.x += 1
	if Input.is_action_pressed("ui_left"): direction.x -= 1
	if Input.is_action_pressed("ui_down"): direction.y += 1
	if Input.is_action_pressed("ui_up"): direction.y -= 1
	
	if direction.length() > 0:
		direction = direction.normalized()
		
	# BEWEGUNG (Speed mal Manager-Speed)
	var s_mult = status_manager.speed_mult if status_manager else 1.0
	velocity = direction * (speed * s_mult)
	move_and_slide()
	
	if velocity.length() > 0:
		anim.play("walk")
		if velocity.x != 0: anim.flip_h = velocity.x < 0
	else:
		anim.play("idle")
		
func gain_xp(amount: float):
	var real_amount = amount * growth
	current_xp += real_amount
	
	var did_level_up = false
	while current_xp >= max_xp:
		current_xp -= max_xp
		level += 1
		max_xp = int(max_xp * 1.2)
		pending_levelups += 1
		did_level_up = true
		
	xp_changed.emit(current_xp, max_xp)
	if did_level_up:
		check_levelups()

func check_levelups():
	if pending_levelups > 0:
		pending_levelups -= 1
		leveled_up.emit()
		
func update_magnet():
	if magnet_shape and magnet_shape.shape:
		magnet_shape.shape.radius = base_magnet_radius * magnet_mult

func _on_magnet_area_entered(area: Area2D):
	if area.is_in_group("XPGem") and area.has_method("fly_to_player"):
		area.fly_to_player(self)

func _on_tick_damage(amount: float, _source: Node2D, color: Color):
	var t_mult = status_manager.dmg_taken_mult if status_manager else 1.0
	take_damage_typed(amount * t_mult, true, color)

func take_damage(dmg_amount: float):
	take_damage_typed(dmg_amount, false, Color(1, 1, 0))

func take_damage_typed(dmg_amount: float, is_dot: bool = false, dmg_color: Color = Color(1, 1, 0)):
	var t_mult = status_manager.dmg_taken_mult if status_manager else 1.0
	var pre_armor_dmg = dmg_amount * t_mult
	var final_damage = max(0, pre_armor_dmg - armor)
	
	if damage_number_scene and final_damage > 0:
		var dmg_num = damage_number_scene.instantiate()
		var offset = Vector2(38, -20)
		var random_offset = Vector2(randf_range(-5, 5), randf_range(-5, 5))
		dmg_num.global_position = global_position + random_offset + offset
		get_tree().current_scene.call_deferred("add_child", dmg_num)
		dmg_num.setup(final_damage, true, is_dot, dmg_color)
	
	if health_component and final_damage > 0:
		health_component.take_damage(final_damage)
		health_changed.emit(health_component.current_health, health_component.max_health)
	
	if not is_dot:
		_flash_hit()

func _flash_hit():
	is_flashing = true
	anim.modulate = Color(0.7, 0, 0)
	await get_tree().create_timer(0.2).timeout
	is_flashing = false

func heal(amount: float):
	if health_component:
		health_component.current_health += amount
		health_component.current_health = min(health_component.current_health, health_component.max_health)
		health_changed.emit(health_component.current_health, health_component.max_health)

func die():
	print("Game Over!") 
	var manager = get_tree().get_first_node_in_group("Managers")
	if manager:
		manager.change_state(manager.GameState.DEAD)
