extends BaseBoss
class_name EyeBoss

enum State { CHASE, PREPARE_LASER, LASER_SWEEP }
var current_state: State = State.CHASE

@export_group("Boss Settings")
@export var laser_dps: float = 25.0 
@export var laser_duration: float = 3.0 # Wie lange der Laser schießt
@export var sweep_arc_degrees: float = 180.0 # Wie weit er in der Zeit wischt (180 = ein halber Kreis)
@export var rotation_smoothing: float = 3.0 # Wie butterweich er den Spieler anvisiert

var state_timer: float = 0.0
var laser_rotation_dir: int = 1 

@onready var laser_pivot = $LaserPivot
@onready var laser_line = $LaserPivot/Line2D # Für den visuellen Dicken-Effekt
@onready var laser_hitbox = $LaserPivot/LaserHitbox

func _ready():
	super._ready()
	max_health = 1500.0
	damage = 15.0 
	
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
			
			# 2. Bewegung zum Spieler
			var direction = (player.global_position - global_position).normalized()
			var s_mult = status_manager.speed_mult if status_manager else 1.0
			velocity = direction * (speed * s_mult)
			move_and_slide()
			
			state_timer += delta
			if state_timer > 6.0: 
				_start_laser_prep()
				
		State.PREPARE_LASER:
			velocity = Vector2.ZERO 
			
			# Er visiert den Spieler in der Vorwarnphase noch weich an!
			var target_angle = (player.global_position - global_position).angle()
			rotation = lerp_angle(rotation, target_angle, rotation_smoothing * 1.5 * delta)
			
			state_timer -= delta
			if state_timer <= 0:
				_start_laser_sweep()
				
		State.LASER_SWEEP:
			# In dieser Phase macht process_movement GAR NICHTS mit der Rotation!
			# Die Drehung wird komplett vom Tween unten gesteuert.
			velocity = Vector2.ZERO 
			_process_laser_damage(delta)

# --- LASER SCHADEN ---
func _process_laser_damage(delta: float):
	var targets = laser_hitbox.get_overlapping_bodies()
	for t in targets:
		# Hier nutzen wir take_damage_typed, wenn dein Spieler das hat.
		if t.is_in_group("player") and t.has_method("take_damage"):
			t.take_damage(laser_dps * delta)

# --- PHASEN-WECHSEL ---
func _start_laser_prep():
	current_state = State.PREPARE_LASER
	state_timer = 1.5 # 1.5 Sekunden Vorwarnzeit
	
	laser_rotation_dir = 1 if randf() > 0.5 else -1
	
	# Visuelles Feedback: Rotes Zittern
	var color_tween = create_tween()
	color_tween.tween_property(anim, "modulate", Color(1, 0.2, 0.2), 0.1)
	color_tween.tween_property(anim, "modulate", Color.WHITE, 0.1)
	color_tween.set_loops(7)
	
	# TELEGRAPH: Wir zeigen einen hauchdünnen, harmlosen Ziellaser!
	if laser_pivot and laser_line:
		laser_pivot.show()
		laser_hitbox.monitoring = false # Noch kein Schaden!
		laser_line.width = 2.0 # Ganz dünner Faden
		laser_line.modulate.a = 0.5 # Halbtransparent

func _start_laser_sweep():
	current_state = State.LASER_SWEEP
	anim.modulate = Color.WHITE
	
	# Laser wird tödlich!
	if laser_pivot and laser_line:
		laser_hitbox.monitoring = true
		laser_line.modulate.a = 1.0
		
		# Laser ploppt fett auf (Juice!)
		var width_tween = create_tween()
		width_tween.tween_property(laser_line, "width", 10.0, 0.2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	# --- DIE MAGIE: Der butterweiche Laser-Sweep ---
	var sweep_tween = create_tween()
	
	# Wir berechnen, wie weit er wischen soll (z.B. 180 Grad nach rechts)
	var sweep_amount = deg_to_rad(sweep_arc_degrees) * laser_rotation_dir
	var start_rotation = rotation
	var target_rotation = rotation + sweep_amount
	
	# TRANS_SINE + EASE_IN_OUT = Startet extrem langsam, schießt dann rüber, bremst weich ab. Perfekt!
	sweep_tween.tween_property(self, "rotation", target_rotation, laser_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Wenn der Tween fertig ist, ist der Sweep vorbei
	sweep_tween.tween_callback(_end_laser_sweep)

func _end_laser_sweep():
	current_state = State.CHASE
	state_timer = 0.0 
	
	# Laser sanft ausblenden
	if laser_pivot and laser_line:
		laser_hitbox.monitoring = false
		var fade_tween = create_tween().set_parallel(true)
		fade_tween.tween_property(laser_line, "width", 0.0, 0.3)
		fade_tween.tween_property(laser_line, "modulate:a", 0.0, 0.3)
		fade_tween.set_parallel(false)
		fade_tween.tween_callback(laser_pivot.hide)
