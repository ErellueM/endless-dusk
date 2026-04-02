extends BaseEnemy

@export_group("Plague Doctor Settings")
@export var attack_range: float = 150.0
@export var acceleration: float = 3.0
@export var shoot_cooldown: float = 2.0

@export_group("Projectile Settings")
@export var projectile_scene: PackedScene
@export var proj_speed: float = 250.0
@export var proj_damage: float = 15.0
@export var proj_charge_time: float = 0.6

var shoot_timer: float = 0.0
var is_shooting: bool = false
var actual_attack_range: float
var strafe_direction: float = 1.0
var strafe_change_timer: float = 0.0

func _ready():
	super._ready()
	enemy_name = "Plague Doctor"
	
	actual_attack_range = attack_range * randf_range(0.8, 1.2)
	shoot_cooldown = shoot_cooldown * randf_range(0.85, 1.15)
	shoot_timer = randf_range(0.2, shoot_cooldown)
	
	strafe_direction = 1.0 if randf() > 0.5 else -1.0
	strafe_change_timer = randf_range(1.5, 4.0)

func process_movement(delta: float):
	if player == null or is_dead: return
	
	shoot_timer -= delta
	strafe_change_timer -= delta
	
	if strafe_change_timer <= 0.0:
		strafe_direction *= -1.0
		strafe_change_timer = randf_range(1.5, 4.0)
	
	var distance = global_position.distance_to(player.global_position)
	
	if player.global_position.x < global_position.x:
		anim.flip_h = false 
		if $ShootPoint: $ShootPoint.position.x = -abs($ShootPoint.position.x)
	else:
		anim.flip_h = true 
		if $ShootPoint: $ShootPoint.position.x = abs($ShootPoint.position.x)
	
	var target_velocity = Vector2.ZERO
	var s_mult = status_manager.speed_mult if status_manager else 1.0
	var current_max_speed = speed * s_mult
	
	if is_shooting:
		target_velocity = Vector2.ZERO
	else:
		var direction = Vector2.ZERO
		if distance > actual_attack_range:
			direction = global_position.direction_to(player.global_position)
		elif distance < actual_attack_range - 20.0:
			direction = player.global_position.direction_to(global_position)
		else:
			direction = global_position.direction_to(player.global_position).rotated((PI/2) * strafe_direction)
			
		target_velocity = direction * current_max_speed

	velocity = velocity.lerp(target_velocity, acceleration * delta)
	move_and_slide()
	
	if is_instance_valid(anim):
		anim.play("default")
	
	if distance <= actual_attack_range and shoot_timer <= 0.0 and not is_shooting:
		shoot()

func shoot():
	is_shooting = true
	shoot_timer = shoot_cooldown
	
	var original_modulate = anim.modulate
	anim.modulate = Color(1.5, 0.4, 0.4) 
	
	var proj = null
	if projectile_scene:
		proj = projectile_scene.instantiate()
		
		var d_mult = 1.0
		if status_manager:
			d_mult = status_manager.dmg_dealt_mult
		
		proj.damage = proj_damage * d_mult
		proj.speed = 0.0 
		proj.scale = Vector2.ZERO
		proj.z_index = z_index + 1
		
		get_tree().current_scene.add_child(proj)
		
		proj.global_position = $ShootPoint.global_position
		
		if proj.has_method("reset_physics_interpolation"):
			proj.reset_physics_interpolation()
			
		var tween = create_tween()
		tween.tween_property(proj, "scale", Vector2.ONE, proj_charge_time).set_trans(Tween.TRANS_BACK)
	
	await get_tree().create_timer(proj_charge_time).timeout 
	
	if is_dead: 
		if proj and is_instance_valid(proj): 
			proj.queue_free()
		return 
	
	anim.modulate = original_modulate
	
	if proj and is_instance_valid(proj):
		proj.global_position = $ShootPoint.global_position
		proj.direction = global_position.direction_to(player.global_position)
		proj.speed = proj_speed 
		
	await get_tree().create_timer(0.25).timeout
	
	is_shooting = false
