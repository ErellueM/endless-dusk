extends CharacterBody2D

signal xp_changed(current, max_val)
signal health_changed(current, max_val)
signal leveled_up

var level: int = 1
var current_xp: float = 0
var max_xp: float = 10.0

@export var damage_number_scene: PackedScene

@export_group("Inventory")
@export var starting_weapons: Array[PackedScene] = []
@export var max_weapons: int = 6

@export_group("Movement")
@export var speed: float = 150.0

@export_group("Survival Stats")
@export var max_health: float = 100.0:
	set(new_value):
		max_health = new_value
		if is_node_ready() and health_component:
			health_component.max_health = max_health
			health_changed.emit(health_component.current_health, health_component.max_health)
@export var armor: float = 0.0
@export var recovery: float = 0.0

@export_group("Offensive Stats")
@export var might: float = 1.0
@export var area: float = 1.0
@export var attack_speed_bonus: float = 0.0

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
@onready var weapon_inventory = $WeaponInventory

var base_magnet_radius: float = 0.0
var pending_levelups: int = 0
var is_flashing: bool = false
var recovery_timer: float = 0.0

func _ready():
	if health_component:
		health_component.max_health = max_health
		health_component.current_health = max_health
		health_component.died.connect(die)

	if magnet_shape and magnet_shape.shape:
		base_magnet_radius = magnet_shape.shape.radius
		update_magnet()
		$MagnetArea.area_entered.connect(_on_magnet_area_entered)

	if status_manager:
		status_manager.apply_tick_damage.connect(_on_tick_damage)

	if weapon_inventory:
		weapon_inventory.max_weapons = max_weapons
		for weapon in starting_weapons:
			weapon_inventory.add_weapon(weapon)

func _physics_process(delta):
	_handle_status_colors()
	_handle_recovery(delta)
	_handle_movement(delta)

func _handle_status_colors():
	if not is_flashing and is_instance_valid(anim) and status_manager:
		anim.modulate = status_manager.color_mod
	elif not is_flashing:
		anim.modulate = Color(1, 1, 1)

func _handle_recovery(delta):
	if health_component and recovery != 0:
		recovery_timer += delta
		if recovery_timer >= 1.0:
			recovery_timer = 0.0
			if recovery > 0:
				# Recovery-Heilung (Silent = true, damit nicht jede Sekunde eine Zahl kommt)
				heal(recovery, true) 
			elif recovery < 0:
				# Negatives Recovery (wie Gift) ignoriert Rüstung!
				take_damage_typed(abs(recovery), true, Color(0.8, 0.2, 0.2))

func _handle_movement(_delta):
	var direction = Vector2.ZERO
	if SettingsManager.mouse_movement and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_pos = get_global_mouse_position()
		if global_position.distance_to(mouse_pos) > 30.0:
			direction = global_position.direction_to(mouse_pos)
	else:
		direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		if direction.length() > 0:
			direction = direction.normalized()

	var s_mult = status_manager.speed_mult if status_manager else 1.0
	velocity = direction * (speed * s_mult)
	move_and_slide()

	if velocity.length() > 0:
		anim.play("walk")
		anim.flip_h = velocity.x < 0
	else:
		anim.play("idle")

func gain_xp(amount: float):
	current_xp += amount * growth
	while current_xp >= max_xp:
		current_xp -= max_xp
		level += 1
		max_xp = int(max_xp * 1.2)
		pending_levelups += 1
	xp_changed.emit(current_xp, max_xp)
	check_levelups()

func check_levelups():
	if pending_levelups > 0:
		pending_levelups -= 1
		leveled_up.emit()

func update_magnet():
	if magnet_shape and magnet_shape.shape:
		magnet_shape.shape.radius = base_magnet_radius * magnet_mult

func _on_magnet_area_entered(area: Area2D):
	if area.has_method("fly_to_player"):
		area.fly_to_player(self)

func _on_tick_damage(amount: float, _source: Node2D, color: Color):
	# Tick-Schaden (Gift) sollte Rüstung ignorieren
	take_damage_typed(amount, true, color)

func take_damage(dmg_amount: float):
	take_damage_typed(dmg_amount, false, Color(1.0, 0.2, 0.2))

func take_damage_typed(dmg_amount: float, is_dot: bool = false, dmg_color: Color = Color(1.0, 0.2, 0.2)):
	var final_damage = dmg_amount
	
	if not is_dot:
		# --- DAS NEUE RÜSTUNGSSYSTEM ---
		if armor >= 0:
			# Die Konstante "50.0" bestimmt, wie schnell man das Cap erreicht.
			# Bei Armor = 50 hast du 50% Reduktion. Bei Armor = 100 hast du 66%.
			var reduction = armor / (armor + 50.0)
			
			# Wir cappen die Reduktion bei maximal 70% (0.7)
			reduction = min(0.7, reduction)
			
			final_damage = dmg_amount * (1.0 - reduction)
		else:
			# Wenn Rüstung NEGATIV ist (z.B. durch Flüche oder bestimmte Charaktere wie den Orc)
			# Nimmt der Spieler prozentual MEHR Schaden! (-10 Armor = +20% Schaden)
			final_damage = dmg_amount * (1.0 - (armor / 50.0))
			
	# Wir stellen sicher, dass Schaden nie unter 1.0 fällt (außer der Basis-Schaden war schon tiefer)
	# So macht jeder Treffer zumindest ein bisschen spürbaren Schaden.
	if not is_dot:
		final_damage = max(1.0, final_damage)
	
	if SettingsManager.show_damage_numbers and final_damage > 0:
		var offset = Vector2(randf_range(-10, 10), randf_range(-10, 10))
		DamagePool.spawn_number(global_position + offset, final_damage, is_dot, dmg_color)

	if health_component and final_damage > 0:
		health_component.take_damage(final_damage)
		health_changed.emit(health_component.current_health, health_component.max_health)

	if not is_dot:
		_flash_hit()

func _flash_hit():
	is_flashing = true
	var prev_mod = anim.modulate
	anim.modulate = Color(10, 10, 10) # Weißer HDR Flash ist deutlicher als Rot
	await get_tree().create_timer(0.1).timeout
	is_flashing = false
	anim.modulate = prev_mod

func heal(amount: float, silent: bool = false):
	if health_component and health_component.current_health < health_component.max_health:
		var actual_heal = min(amount, health_component.max_health - health_component.current_health)
		health_component.current_health += actual_heal
		health_changed.emit(health_component.current_health, health_component.max_health)

		# Nur Zahlen zeigen, wenn nicht 'silent' (verhindert Spam durch Recovery)
		if not silent and SettingsManager.show_damage_numbers and actual_heal > 0:
			var offset = Vector2(randf_range(-10, 10), randf_range(-10, 10))
			DamagePool.spawn_number(global_position + offset, actual_heal, false, Color(0.2, 1.0, 0.2))

func die():
	var manager = get_tree().get_first_node_in_group("Managers")
	if manager:
		manager.change_state(manager.GameState.DEAD)
