extends BaseEnemy

@export_group("Plague Doctor Settings")
@export var attack_range: float = 150.0
@export var acceleration: float = 3.0 # Wie weich er anfährt und abbremst (kleiner = weicher)
var shoot_cooldown: float = 2.0
var shoot_timer: float = 0.0
var is_shooting: bool = false

@export_group("Projectile Settings")
@export var projectile_scene: PackedScene
@export var proj_speed: float = 250.0
@export var proj_damage: float = 15.0
@export var proj_charge_time: float = 0.6 # Wie lange die Kugel wächst

func _ready():
	super._ready()
	enemy_name = "Plague Doctor"
	speed = 60.0
	damage = 5.0

func process_movement(delta: float):
	if player == null or is_dead: return
	
	shoot_timer -= delta
	var distance = global_position.distance_to(player.global_position)
	
	# --- 1. RICHTUNG & SPAWNPUNKT ---
	if player.global_position.x < global_position.x:
		anim.flip_h = false 
		if $ShootPoint: $ShootPoint.position.x = -abs($ShootPoint.position.x)
	else:
		anim.flip_h = false 
		if $ShootPoint: $ShootPoint.position.x = abs($ShootPoint.position.x)
	
	# --- 2. ZIEL-GESCHWINDIGKEIT BERECHNEN ---
	var target_velocity = Vector2.ZERO
	var s_mult = status_manager.speed_mult if status_manager else 1.0
	var current_max_speed = speed * s_mult
	
	if is_shooting:
		# Beim Schießen soll er stehen bleiben (Ziel-Speed = 0)
		target_velocity = Vector2.ZERO
	else:
		# Kiting-Logik (Abstand halten)
		var direction = Vector2.ZERO
		if distance > attack_range:
			direction = global_position.direction_to(player.global_position)
		elif distance < attack_range - 20.0:
			direction = player.global_position.direction_to(global_position)
		else:
			direction = global_position.direction_to(player.global_position).rotated(PI/2)
			
		target_velocity = direction * current_max_speed

	# --- 3. SMOOTH MOVEMENT (LERP) ---
	# velocity gleitet weich zur target_velocity. 
	# Das verhindert das ruckartige "0 auf 100"!
	velocity = velocity.lerp(target_velocity, acceleration * delta)
	move_and_slide()
	
	# Animation anpassen, je nachdem ob er steht oder läuft
	if velocity.length() > 10.0 and not is_shooting:
		anim.play("default")
	elif not is_shooting:
		anim.play("idle")
	
	# --- 4. SCHIESSEN AUSLÖSEN ---
	if distance <= attack_range and shoot_timer <= 0.0 and not is_shooting:
		shoot()

func shoot():
	is_shooting = true
	shoot_timer = shoot_cooldown
	anim.play("idle") # Zur Sicherheit auf Stand-Animation wechseln
	
	var original_modulate = anim.modulate
	anim.modulate = Color(1.5, 0.4, 0.4) 
	
	var proj = null
	if projectile_scene:
		proj = projectile_scene.instantiate()
		get_tree().current_scene.add_child(proj)
		
		# Kugel vor den Doktor zeichnen! (z_index höher machen)
		proj.z_index = z_index + 1
		
		proj.global_position = $ShootPoint.global_position
		
		# WICHTIG: Variablen aus dem Inspektor an die Kugel übergeben
		proj.damage = proj_damage
		proj.speed = 0.0 
		
		proj.scale = Vector2.ZERO
		var tween = create_tween()
		tween.tween_property(proj, "scale", Vector2.ONE, proj_charge_time).set_trans(Tween.TRANS_BACK)
	
	# Warten bis die Kugel fertig gewachsen ist (proj_charge_time)
	await get_tree().create_timer(proj_charge_time).timeout 
	
	if is_dead: 
		if proj and is_instance_valid(proj): 
			proj.queue_free()
		return 
	
	anim.modulate = original_modulate
	
	if proj and is_instance_valid(proj):
		proj.global_position = $ShootPoint.global_position
		proj.direction = global_position.direction_to(player.global_position)
		# Jetzt geben wir der Kugel den eingestellten Speed!
		proj.speed = proj_speed 
		
	is_shooting = false
