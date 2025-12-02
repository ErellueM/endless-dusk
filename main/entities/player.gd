extends CharacterBody2D

# --- STATS FÜR DEN GAME DESIGNER (im Inspector editierbar) ---

@export_group("Movement")
@export var speed: float = 200.0

@export_group("Survival Stats")
@export var max_health: float = 100.0
@export var armor: float = 0.0          # Reduziert direkten Schaden
@export var recovery: float = 0.0       # Lebensregeneration pro Sekunde

@export_group("Offensive Stats")
@export var might: float = 1.0          # Schaden in Prozent (1.0 = 100%, 1.5 = 150%)
@export var area: float = 1.0           # Angriffsgröße (Area of Effect)
@export var cooldown_mult: float = 1.0  # Cooldown Reduktion (0.9 = 10% schneller)

@export_group("Utility Stats")
@export var magnet_range: float = 100.0 # Radius zum Einsammeln von XP
@export var growth: float = 1.0         # XP Multiplikator (schneller Leveln) [cite: 9]

# Interne Variablen (nicht im Inspector sichtbar)
var current_health: float
@onready var anim = $AnimatedSprite2D

func _ready():
	# Leben beim Start auffüllen
	current_health = max_health
	
	# Optional: Start-Check
	print("Spieler geladen mit ", max_health, " HP und ", might, "x Schaden.")

func _physics_process(delta):
	# 1. REGENERATION
	if current_health < max_health and recovery > 0:
		current_health += recovery * delta
		current_health = min(current_health, max_health) # Nicht über Max heilen

	# 2. BEWEGUNG (INPUT)
	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	# Input normalisieren (damit man diagonal nicht schneller ist)
	if direction.length() > 0:
		direction = direction.normalized()
	
	# Velocity setzen (CharacterBody2D Eigenschaft)
	velocity = direction * speed
	
	# Physik-Bewegung ausführen (gleitet an Wänden entlang)
	move_and_slide()

	# 3. ANIMATIONEN
	if velocity.length() > 0:
		anim.play("walk")
		# Sprite spiegeln je nach Richtung
		if velocity.x != 0:
			anim.flip_h = velocity.x < 0
	else:
		anim.play("idle")
		
	# 4. TEST-ANGRIFF (Nur zum Debuggen)
	if Input.is_action_just_pressed("ui_accept"):
		print("Angriff mit ", might * 100, "% Schaden!")

# --- FUNKTIONEN FÜR SCHADEN & HEILUNG ---

# Diese Funktion wird später vom Gegner aufgerufen: player.take_damage(10)
func take_damage(dmg_amount: float):
	# Armor berechnen: Schaden minus Rüstung (aber nicht unter 0)
	var final_damage = max(0, dmg_amount - armor)
	
	current_health -= final_damage
	print("Getroffen! Schaden: ", final_damage, " | Rest-HP: ", current_health)
	
	# Blink-Effekt (optional, wenn du einen Shader oder Modulate nutzt)
	anim.modulate = Color(1, 0, 0) # Rot färben
	await get_tree().create_timer(0.1).timeout
	anim.modulate = Color(1, 1, 1) # Normal färben

	if current_health <= 0:
		die()

func heal(amount: float):
	current_health += amount
	current_health = min(current_health, max_health)
	print("Geheilt um ", amount)

func die():
	print("Game Over! Du hast überlebt bis Level...") 
	# Hier später: Game Over Screen anzeigen oder Szene neu laden
	# get_tree().reload_current_scene()
