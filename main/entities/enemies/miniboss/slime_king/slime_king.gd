extends BaseEnemy

# Zustände für den Schleim
enum State { CHASE, PREPARE, JUMP, REST }
var current_state: State = State.CHASE

@export_group("Jump Attack Settings")
@export var jump_speed: float = 450.0 # Wie schnell er durch die Luft fliegt
@export var jump_range: float = 140.0 # Ab welcher Distanz er springt
@export var prepare_time: float = 0.6 # Wie lange er sich vor dem Sprung auflädt
@export var jump_duration: float = 0.6 # Wie lange der Sprung dauert
@export var rest_time: float = 1.2 # Pause nach der Landung

var jump_direction: Vector2 = Vector2.ZERO

func _ready():
	enemy_name = "Jump Slime"
	super._ready() # Ruft das Setup von BaseEnemy auf

# Wir überschreiben die Bewegung aus dem BaseEnemy
func process_movement(_delta: float):
	match current_state:
		State.CHASE:
			# Normale Bewegung aufrufen
			super.process_movement(_delta)
			
			# Prüfen, ob der Spieler in Reichweite für einen Sprung ist
			if global_position.distance_to(player.global_position) <= jump_range:
				start_jump_attack()
				
		State.PREPARE:
			# Stehen bleiben und aufladen
			velocity = Vector2.ZERO
			move_and_slide()
			
		State.JUMP:
			# Schnell in die gespeicherte Richtung fliegen (Dash)
			var s_mult = status_manager.speed_mult if status_manager else 1.0
			velocity = jump_direction * (jump_speed * s_mult)
			move_and_slide()
			
		State.REST:
			# Erschöpft liegen bleiben
			velocity = Vector2.ZERO
			move_and_slide()

func start_jump_attack():
	# 1. AUFLADEN (PREPARE)
	current_state = State.PREPARE
	
	# Visueller Effekt: Schleim staucht sich zusammen (Squash)
	if is_instance_valid(anim):
		var tween = create_tween()
		tween.tween_property(anim, "scale", Vector2(1.3, 0.7), prepare_time)
	
	await get_tree().create_timer(prepare_time).timeout
	if is_dead: return
	
	# 2. SPRINGEN (JUMP)
	current_state = State.JUMP
	# Richtung zum Spieler GENAU im Moment des Absprungs berechnen
	jump_direction = (player.global_position - global_position).normalized()
	
	# Visueller Effekt: Schleim streckt sich in der Luft (Stretch)
	if is_instance_valid(anim):
		var tween = create_tween()
		tween.tween_property(anim, "scale", Vector2(0.8, 1.2), jump_duration * 0.5)
		tween.tween_property(anim, "scale", Vector2(1.0, 1.0), jump_duration * 0.5)
	
	await get_tree().create_timer(jump_duration).timeout
	if is_dead: return
	
	# 3. LANDEN & AUSRUHEN (REST)
	current_state = State.REST
	
	# Visueller Effekt: Fetter Aufprall
	if is_instance_valid(anim):
		var tween = create_tween()
		tween.tween_property(anim, "scale", Vector2(1.4, 0.6), 0.1)
		tween.tween_property(anim, "scale", Vector2(1.0, 1.0), 0.3)
	
	await get_tree().create_timer(rest_time).timeout
	if is_dead: return
	
	# 4. ZURÜCK ZUR JAGD (CHASE)
	current_state = State.CHASE
