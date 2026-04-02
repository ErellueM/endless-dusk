extends BaseEnemy

@export_group("Tollkeeper Settings")
@export var keep_distance: float = 200.0
@export var buff_radius: float = 200.0
@export var buff_cooldown: float = 10.0
@export var buff_duration: float = 12.0
@export var buff_multiplier: float = 1.5 

var buff_timer: float = 3.0 
var is_casting: bool = false
var original_anim_pos: Vector2 = Vector2.ZERO

func _ready():
	super._ready()
	original_anim_pos = anim.position

func process_movement(delta: float):
	if is_casting:
		# Während des Schlagens und Vibrierens NICHT bewegen!
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	buff_timer -= delta
	if buff_timer <= 0.0:
		cast_buff_sequence()
		return
	
	# --- KITING LOGIK ---
	var distance_to_player = global_position.distance_to(player.global_position)
	var direction = Vector2.ZERO
	
	if distance_to_player < keep_distance - 20.0:
		direction = player.global_position.direction_to(global_position) # Weglaufen
	elif distance_to_player > keep_distance + 20.0:
		direction = global_position.direction_to(player.global_position) # Hinlaufen
	else:
		direction = global_position.direction_to(player.global_position).rotated(PI/2)
		
	var s_mult = status_manager.speed_mult if status_manager else 1.0
	velocity = velocity.lerp(direction * (speed * s_mult), 3.0 * delta)
	move_and_slide()
	
	if velocity.x != 0:
		anim.flip_h = velocity.x < 0
	
	# Da er sich beim Laufen nicht animiert, bleibt er immer auf "default"
	anim.play("default")

func cast_buff_sequence():
	is_casting = true
	buff_timer = buff_cooldown
	
	# 1. Ausholen und Schlagen
	anim.play("attack") 
	
	# Wir warten, bis deine 10-Frame-Animation exakt fertig ist
	await anim.animation_finished 
	
	if is_dead: return 
	
	# 2. DER SCHLAG (BÄÄÄM)
	spawn_dust_shockwave()
	apply_buff_to_all_in_radius()
	trigger_screenshake()
	
	# 3. Zurück zur normalen Pose
	anim.play("default")
	
	# 4. DAS VIBRIEREN (Die Nachwehen des Glockenschlags)
	# Wir lassen ihn für 2 Sekunden stark vibrieren
	var vibration_time = 2.0
	var timer = 0.0
	while timer < vibration_time:
		if is_dead: return
		
		# Zufälliges Rütteln des Sprites (±3 Pixel hin und her)
		var shake_x = randf_range(-3.0, 3.0)
		var shake_y = randf_range(-1.0, 1.0)
		anim.position = original_anim_pos + Vector2(shake_x, shake_y)
		
		var delta_wait = 0.05
		await get_tree().create_timer(delta_wait).timeout
		timer += delta_wait
		
	# Sprite wieder perfekt mittig setzen
	if not is_dead:
		anim.position = original_anim_pos
		is_casting = false

func spawn_dust_shockwave():
	# Wir instanziieren unser neues Skript einfach als Node
	var shockwave = DustShockwave.new()
	shockwave.max_radius = buff_radius
	
	# Den Effekt exakt unter dem Gegner spawnen (am Boden)
	var offset = Vector2(0, 10) 
	shockwave.global_position = global_position + offset
	get_tree().current_scene.call_deferred("add_child", shockwave)

func apply_buff_to_all_in_radius():
	var all_enemies = get_tree().get_nodes_in_group("Enemygroup")
	
	for e in all_enemies:
		if e == self or e.is_dead: continue
		if e.enemy_name == self.enemy_name: continue 
		
		if global_position.distance_to(e.global_position) <= buff_radius:
			var s_manager = e.get_node_or_null("StatusManager")
			if s_manager:
				s_manager.add_effect(BloodlustEffect.new(buff_duration, buff_multiplier))

func trigger_screenshake():
	# HIER KOMMT DEIN KAMERA-SHAKE HIN. 
	# Z.B.:
	var camera = get_tree().get_first_node_in_group("camera")
	if camera and camera.has_method("shake"):
		camera.shake(0.3, 8.0) # Dauer 0.3s, Stärke 8.0
