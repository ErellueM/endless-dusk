extends BaseEnemy

@export var charge_speed: float = 400.0
@export var charge_duration: float = 0.5
@export var cooldown_base: float = 1.5  # mittlere Cooldown Zeit
@export var cooldown_random: float = 1.0  # +- Sekunden

@export var max_charges: int = 3  # nach 3 Charges stirbt er

var is_charging: bool = false
var charge_direction: Vector2 = Vector2.ZERO
var is_in_cycle: bool = false
var charge_count: int = 0
var has_dealt_damage = false

func _ready():
	super._ready()
	speed = 0  # steht erstmal still

func _physics_process(delta):
	if is_dead:
		return
	
	if player == null:
		return
	
	if is_charging:
		velocity = charge_direction * charge_speed
		move_and_slide()
		
		if anim:
			anim.flip_h = velocity.x < 0
			anim.rotation = charge_direction.angle() + 90
		return
		
	if is_charging and not has_dealt_damage:
		var overlapping_bodies = attack_area.get_overlapping_bodies()
		for body in overlapping_bodies:
			if body.is_in_group("player") and body.has_method("take_damage"):
				body.take_damage(damage)
				has_dealt_damage = true
				start_attack_cooldown()
				break
	
	velocity = Vector2.ZERO
	
	if not is_in_cycle:
		is_in_cycle = true
		await start_charge_cycle()
		is_in_cycle = false

# --- Charge Ablauf ---
func start_charge_cycle() -> void:
	if charge_count >= max_charges:
		queue_free()
		return

	# kurze Pause / "Zielen"
	await get_tree().create_timer(0.5).timeout
	
	if player == null:
		return
	
	# Richtung zum Spieler speichern
	charge_direction = (player.global_position - global_position).normalized()
	
	# START CHARGE
	is_charging = true
	charge_count += 1
	
	await get_tree().create_timer(charge_duration).timeout
	
	# STOP
	is_charging = false
	velocity = Vector2.ZERO
	
	# Cooldown randomisiert
	var cooldown_time = cooldown_base + randf_range(-cooldown_random, cooldown_random)
	await get_tree().create_timer(cooldown_time).timeout
