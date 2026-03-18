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
@export var armor: float = 0.0          # Reduziert direkten Schaden
@export var recovery: float = 0.0       # Lebensregeneration pro Sekunde

@export_group("Offensive Stats")
@export var might: float = 1.0          # Schaden in Prozent (1.0 = 100%, 1.5 = 150%)
@export var area: float = 1.0           # Angriffsgröße (Area of Effect)
@export var cooldown_mult: float = 1.0  # Cooldown Reduktion (0.9 = 10% schneller)

@export_group("Utility Stats")
@export var magnet_mult: float = 1.0 
@export var growth: float = 1.0         # XP Multiplikator (schneller Leveln) [cite: 9]
@export var luck: float = 1.0


@onready var health_component = $Health
@onready var anim = $AnimatedSprite2D
@onready var magnet_shape = $MagnetArea/CollisionShape2D

var base_magnet_radius: float = 0.0

func _ready():
	if health_component:
		health_component.died.connect(die)
		print("Spieler geladen mit ", health_component.max_health, " HP.")
		
	if magnet_shape and magnet_shape.shape:
		base_magnet_radius = magnet_shape.shape.radius 
		update_magnet()
		$MagnetArea.area_entered.connect(_on_magnet_area_entered)
	
	# Optional: Start-Check
	print("Spieler geladen mit ", max_health, " HP und ", might, "x Schaden.")

func _physics_process(delta):
	# 1. REGENERATION
	if health_component and recovery > 0:
		if health_component.current_health < health_component.max_health:
			health_component.current_health += recovery * delta
			health_component.current_health = min(health_component.current_health, health_component.max_health)
			health_changed.emit(health_component.current_health, health_component.max_health)

	# 2. BEWEGUNG (INPUT)
	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	
	if direction.length() > 0:
		direction = direction.normalized()
	velocity = direction * speed
	move_and_slide()
	
	if velocity.length() > 0:
		anim.play("walk")
		if velocity.x != 0:
			anim.flip_h = velocity.x < 0
	else:
		anim.play("idle")
		
	# 4. TEST-ANGRIFF (Nur zum Debuggen)
	if Input.is_action_just_pressed("ui_accept"):
		print("Angriff mit ", might * 100, "% Schaden!")
		

func gain_xp(amount: float):
	var real_amount = amount * growth
	current_xp += real_amount
	
	while current_xp >= max_xp:
		_handle_levelup()
	xp_changed.emit(current_xp, max_xp)

func _handle_levelup():
	var overflow = current_xp - max_xp
	level += 1
	current_xp = 0.0
	max_xp = int(max_xp * 1.2) # +10
	leveled_up.emit()
	if overflow > 0:
		gain_xp(overflow)
		
func update_magnet():
	if magnet_shape and magnet_shape.shape:
		magnet_shape.shape.radius = base_magnet_radius * magnet_mult

func _on_magnet_area_entered(area: Area2D):
	if area.is_in_group("XPGem") and area.has_method("fly_to_player"):
		area.fly_to_player(self)

func take_damage(dmg_amount: float):
	var final_damage = max(0, dmg_amount - armor)
	
	if damage_number_scene:
		var dmg_num = damage_number_scene.instantiate()
		var offset = Vector2(+38, -20)
		var random_offset = Vector2(randf_range(-5, 5), randf_range(-5, 5))
		dmg_num.global_position = global_position + random_offset + offset
		get_tree().current_scene.call_deferred("add_child", dmg_num)
		dmg_num.setup(final_damage, true)
	
	if health_component:
		health_component.take_damage(final_damage)
		print("Hit! DMG: ", final_damage, " | HP: ", health_component.current_health)
		health_changed.emit(health_component.current_health, health_component.max_health)
	
	anim.modulate = Color(0.7, 0, 0)
	await get_tree().create_timer(0.2).timeout
	anim.modulate = Color(1, 1, 1)


func heal(amount: float):
	if health_component:
		health_component.current_health += amount
		health_component.current_health = min(health_component.current_health, health_component.max_health)
		print("Healed ", amount, " | HP: ", health_component.current_health)
		health_changed.emit(health_component.current_health, health_component.max_health)

func die():
	print("Game Over!") 
	var manager = get_tree().get_first_node_in_group("Managers")
	
	if manager:
		manager.change_state(manager.GameState.DEAD)
