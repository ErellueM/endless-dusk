extends CharacterBody2D

signal xp_changed(current, max_val)
signal leveled_up()

# Level System Variablen
var level: int = 1
var current_xp: float = 9.0
var max_xp: float = 10.0 # Startwert für Level 1

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
		

# Wird aufgerufen, wenn du einen XP-Stein (Soul Gem) aufsammelst
func gain_xp(amount: float):
	# Growth Stat einberechnen (Mehr XP wenn Growth höher ist)
	var real_amount = amount * growth
	current_xp += real_amount
	
	# Checken, ob wir aufsteigen
	if current_xp >= max_xp:
		_handle_levelup()
		
	# UI benachrichtigen
	xp_changed.emit(current_xp, max_xp)

func _handle_levelup():
	# 1. Überschüssige XP berechnen (damit nichts verloren geht)
	var overflow = current_xp - max_xp
	
	# 2. Level erhöhen
	level += 1
	current_xp = 0.0
	
	# 3. Nächstes Level schwerer machen (Kurve)
	# Formel: Jedes Level braucht 20% mehr XP + fix 10
	max_xp = int(max_xp * 1.2) + 10
	
	# 4. Signal senden (Damit das Spiel pausiert und Menü aufgeht)
	leveled_up.emit()
	
	# 5. Rekursion: Falls der Overflow so groß war, dass wir NOCHMAL aufsteigen
	if overflow > 0:
		gain_xp(overflow)

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
