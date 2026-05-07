extends BaseBoss
class_name EyeBoss

enum State { CHASE, PREPARE_LASER, LASER_SWEEP }
var current_state: State = State.CHASE

@export_group("Boss Settings")
@export var laser_duration: float = 3.0 # Wie lange der Laser schießt
@export var sweep_arc_degrees: float = 180.0 # Wie weit er wischt
@export var rotation_smoothing: float = 3.0 # Wie weich er anvisiert

var state_timer: float = 0.0
var laser_rotation_dir: int = 1 

# --- DER NEUE TICK-TIMER FÜR DEN LASER ---
var laser_tick_timer: float = 0.0
var laser_tick_rate: float = 0.25 # Macht 4x pro Sekunde Schaden (Performance-freundlich!)

@onready var laser_pivot = $LaserPivot
@onready var laser_line = $LaserPivot/Line2D
@onready var laser_hitbox = $LaserPivot/LaserHitbox

func _ready():
	super._ready()
	# Deine Szene stellt max_health auf 8000 und damage auf 20, das übernimmt BaseBoss automatisch!
	
	if laser_pivot:
		laser_pivot.hide()
		laser_hitbox.monitoring = false

# --- DIE SMOOTHE STATE MACHINE ---
func process_movement(delta: float):
	match current_state:
		State.CHASE:
			# 1. Butterweiche Rotation zum Spieler
			var target_angle = (player.global_position - global_position).angle()
			rotation = lerp_angle(rotation, target_angle, rotation_smoothing * delta)
			
			# 2. Bewegung
			var direction = (player.global_position - global_position).normalized()
			var s_mult = status_manager.speed_mult if status_manager else 1.0
			velocity = direction * (speed * s_mult)
			move_and_slide()
			
			state_timer += delta
			if state_timer > 6.0: 
				_start_laser_prep()
				
		State.PREPARE_LASER:
			velocity = Vector2.ZERO 
			
			# Er visiert weich an, ABER: Er friert in der letzten halben Sekunde ein!
			# So kann der Spieler ihn "baiten" (ausweichen), kurz bevor er schießt.
			if state_timer > 0.5:
				var target_angle = (player.global_position - global_position).angle()
				rotation = lerp_angle(rotation, target_angle, rotation_smoothing * 2.0 * delta)
			
			state_timer -= delta
			if state_timer <= 0:
				_start_laser_sweep()
				
		State.LASER_SWEEP:
			velocity = Vector2.ZERO 
			_process_laser_damage(delta)

# --- LASER SCHADEN (PERFORMANCE FIX) ---
func _process_laser_damage(delta: float):
	laser_tick_timer -= delta
	
	if laser_tick_timer <= 0:
		laser_tick_timer = laser_tick_rate # Timer wieder aufladen
		
		var targets = laser_hitbox.get_overlapping_bodies()
		for t in targets:
			if t.is_in_group("player") and t.has_method("take_damage_typed"):
				# Der Laser macht pro Tick den Basis-Schaden * 1.5. 
				# Wenn Base Damage 20 ist, macht ein Tick 30 Schaden. (120 Schaden pro Sekunde!)
				# Das wird vom WaveManager wunderbar mit hochskaliert!
				var tick_damage = damage * 2 
				t.take_damage_typed(tick_damage, false, Color(1.0, 0.2, 0.2))

# --- PHASEN-WECHSEL ---
func _start_laser_prep():
	current_state = State.PREPARE_LASER
	state_timer = 1.5 # 1.5 Sekunden Vorwarnzeit
	
	# --- DER SMART AIM FIX ---
	# Wir berechnen den Winkel zum Spieler und vergleichen ihn mit der aktuellen Blickrichtung
	var angle_to_player = global_position.angle_to_point(player.global_position)
	var diff = angle_difference(rotation, angle_to_player)
	
	# Wenn der Spieler (von der Mittellinie aus) eher rechts ist, wische nach rechts (1). Sonst links (-1).
	if diff > 0:
		laser_rotation_dir = 1
	else:
		laser_rotation_dir = -1
	# -------------------------
	
	var color_tween = create_tween()
	color_tween.tween_property(anim, "modulate", Color(1, 0.2, 0.2), 0.1)
	color_tween.tween_property(anim, "modulate", Color.WHITE, 0.1)
	color_tween.set_loops(7)
	
	if laser_pivot and laser_line:
		laser_pivot.show()
		laser_hitbox.set_deferred("monitoring", false)
		laser_line.width = 2.0
		laser_line.modulate.a = 0.5

func _start_laser_sweep():
	current_state = State.LASER_SWEEP
	anim.modulate = Color.WHITE
	laser_tick_timer = 0.0 # Erster Schaden direkt bei Berührung!
	
	if laser_pivot and laser_line:
		laser_hitbox.set_deferred("monitoring", true)
		laser_line.modulate.a = 1.0
		
		var width_tween = create_tween()
		width_tween.tween_property(laser_line, "width", 25.0, 0.2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	var sweep_tween = create_tween()
	var sweep_amount = deg_to_rad(sweep_arc_degrees) * laser_rotation_dir
	var target_rotation = rotation + sweep_amount
	
	sweep_tween.tween_property(self, "rotation", target_rotation, laser_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	sweep_tween.tween_callback(_end_laser_sweep)

func _end_laser_sweep():
	current_state = State.CHASE
	state_timer = 0.0 
	
	if laser_pivot and laser_line:
		laser_hitbox.set_deferred("monitoring", false)
		var fade_tween = create_tween().set_parallel(true)
		fade_tween.tween_property(laser_line, "width", 0.0, 0.3)
		fade_tween.tween_property(laser_line, "modulate:a", 0.0, 0.3)
		fade_tween.set_parallel(false)
		fade_tween.tween_callback(laser_pivot.hide)
