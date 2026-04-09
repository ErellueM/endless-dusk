extends Area2D
class_name DumbSwarmEnemy

# Wir machen diese Werte @export, damit wir gleich ganz leicht 3 Slime-Arten machen können!
@export var enemy_name: String = "Green Slime"
@export var max_health: float = 5.0
@export var speed: float = 60.0
@export var damage: float = 2.0
@export var xp_reward: float = 0.5

var current_health: float
var player: Node2D
var is_dead: bool = false

@onready var sprite = $Sprite2D # Ändere das zu $AnimatedSprite2D, falls du Animationen nutzt

func _ready():
	add_to_group("Enemygroup")
	player = get_tree().get_first_node_in_group("player")
	current_health = max_health
	
	# Winzige Speed-Variation, damit sie nicht exakt ineinander stecken
	speed = speed * randf_range(0.9, 1.1) 
	
	# Signal verbinden: Wenn er den Spieler berührt, macht er Schaden
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	if is_dead or not player: return
	
	# --- BEWEGUNG OHNE PHYSIK-LAG ---
	# Anstatt velocity und move_and_slide nutzen wir reine Mathematik:
	var move_amount = speed * delta
	global_position = global_position.move_toward(player.global_position, move_amount)
	
	# Sprite in die richtige Richtung drehen
	if player.global_position.x < global_position.x:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

# --- SCHADEN NEHMEN ---
func take_damage(amount: float, show_number: bool = true) -> float:
	if is_dead: return 0.0
	
	current_health -= amount
	
	# Deine schönen Schadenszahlen nutzen!
	if show_number and SettingsManager.show_damage_numbers and amount > 0:
		var offset = Vector2(randf_range(-10, 10), randf_range(-20, -10))
		DamagePool.spawn_number(global_position + offset, amount, false, Color(1, 1, 1))
		
	# Ein simpler, lagfreier Hit-Flash
	sprite.modulate = Color(1, 0, 0)
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.15)
	
	if current_health <= 0:
		die()
		
	return amount

# --- STERBEN & XP DROPPEN ---
func die():
	is_dead = true
	Global.register_kill(enemy_name)
	
	# Nutzt direkt deinen perfekten XpPool!
	if xp_reward > 0:
		XpPool.spawn_gem(global_position, xp_reward)
		
	queue_free()

# --- SCHADEN AUSTEILEN ---
func _on_body_entered(body: Node2D):
	if is_dead: return
	if body.is_in_group("player") and body.has_method("take_damage_typed"):
		# Fügt dem Spieler Schaden zu, wenn er ihn berührt
		body.take_damage_typed(damage)
