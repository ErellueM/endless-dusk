extends Area2D
class_name DumbSwarmEnemy

@export_group("Base Stats")
@export var enemy_name: String = "Green Slime"
@export var max_health: float = 5.0
@export var speed: float = 60.0
@export var damage: float = 2.0
@export var xp_reward: float = 0.5

@export_group("Visuals")
# WICHTIG: Stell hier im Inspektor die Farbe deines Slimes ein (z.B. Blau oder Grün)
@export var base_color: Color = Color(1, 1, 1)

var current_health: float
var player: Node2D
var is_dead: bool = false

# --- STATUS VARIABLEN (Für performantes Color-Mixing) ---
var speed_modifier: float = 1.0
var is_iced: bool = false
var is_buffed: bool = false
var is_flashing: bool = false  # Für den Hit-Flash (Schaden nehmen)

@onready var sprite = $AnimatedSprite2D


func _ready():
	add_to_group("Enemygroup")
	add_to_group("SwarmEnemies")
	player = get_tree().get_first_node_in_group("player")
	current_health = max_health

	# Kleiner Speed-Zufall, damit sie nicht alle exakt gleich schnell sind
	speed = speed * randf_range(0.9, 1.1)

	body_entered.connect(_on_body_entered)

	# Initialfarbe setzen
	_update_visual_state()


func _physics_process(delta: float):
	if is_dead or not player:
		return

	var move_amount = (speed * speed_modifier) * delta
	global_position = global_position.move_toward(player.global_position, move_amount)

	var dir_x = player.global_position.x - global_position.x
	if abs(dir_x) > 1.0:
		sprite.flip_h = dir_x < 0


# --- FARB-LOGIK (Mischen ohne Shader) ---
func _update_visual_state():
	if is_flashing:
		return  # Während des Hit-Flashs keine Statusfarben erzwingen

	var final_color = base_color

	# EIS-EFFEKT: Macht das Sprite bläulich (Multiplikation)
	if is_iced:
		final_color *= Color(0.6, 0.6, 2.5)  # Verstärkt Blau-Kanal (HDR)

	# BUFF-EFFEKT: Macht das Sprite rötlich-leuchtend (HDR)
	if is_buffed:
		final_color *= Color(2.5, 0.5, 0.5)  # Verstärkt Rot-Kanal massiv

	sprite.modulate = final_color


# --- EFFEKT-STEUERUNG (Wird von Waffen/Buffern aufgerufen) ---
func apply_lite_buff(duration: float, multiplier: float):
	if is_dead:
		return
	is_buffed = true
	speed_modifier = multiplier
	_update_visual_state()
	# Timer-Logik für das Ende des Buffs
	var tween = create_tween()
	tween.tween_interval(duration)
	tween.tween_callback(
		func():
			is_buffed = false
			speed_modifier = 1.0
			_update_visual_state()
	)


# --- SCHADEN NEHMEN ---
func take_damage(amount: float, show_number: bool = true) -> float:
	if is_dead:
		return 0.0

	current_health -= amount

	# Schadenszahlen (Nur wenn gewünscht)
	if show_number and SettingsManager.show_damage_numbers and amount > 0:
		var offset = Vector2(randf_range(-10, 10), randf_range(-20, -10))
		DamagePool.spawn_number(global_position + offset, amount, false, Color(1, 1, 1))

	# HIT-FLASH (Kurzes Aufleuchten)
	is_flashing = true
	sprite.modulate = Color(10, 10, 10)  # Extremes HDR-Weiß für den Flash

	var flash_tween = create_tween()
	flash_tween.tween_interval(0.1)
	flash_tween.tween_callback(
		func():
			is_flashing = false
			_update_visual_state()
	)

	if current_health <= 0:
		die()

	return amount


# --- STERBEN & XP ---
# --- STERBEN (AB IN DEN POOL) ---
func die():
	if is_dead:
		return
	is_dead = true
	Global.register_kill(enemy_name)

	if xp_reward > 0:
		XpPool.spawn_gem(global_position, xp_reward)

	# Anstatt queue_free() schicken wir ihn ins Lager!
	EnemyPool.return_enemy(self)


# --- AUFWACHEN (Wird vom WaveManager gerufen) ---
func revive(new_pos: Vector2, new_health: float, new_damage: float, new_xp: float):
	is_dead = false
	current_health = new_health
	max_health = new_health
	damage = new_damage
	xp_reward = new_xp

	# Alles zurücksetzen
	speed_modifier = 1.0
	is_iced = false
	is_buffed = false
	is_flashing = false
	_update_visual_state()  # Deine Farb-Funktion von vorhin!

	global_position = new_pos

	# Wieder aufwecken!
	visible = true
	set_process(true)
	set_physics_process(true)


# --- SPIELER BERÜHREN ---
func _on_body_entered(body: Node2D):
	if is_dead:
		return
	if body.is_in_group("player") and body.has_method("take_damage_typed"):
		body.take_damage_typed(damage)
