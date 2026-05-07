extends BaseBoss
class_name RicochetBoss

enum State { REST, AIMING, DASHING }
var current_state: State = State.REST

@export_group("Pinball Settings")
@export var dash_speed: float = 800.0 # Schön schnell!
@export var max_bounces: int = 4 # Wie oft er an Wänden abprallt, bevor er stoppt

var state_timer: float = 0.0
var bounces_left: int = 0
var base_boss_damage: float = 20.0

# Eine einfache Line2D als Kind-Node (für die Ziel-Linie)
@onready var aim_line = $AimLine 

func _ready():
	super._ready()
	#max_health = 2000.0
	base_boss_damage = damage
	print(max_health)
	print(damage)
	if aim_line:
		aim_line.hide()
		aim_line.width = 3.0
		aim_line.default_color = Color(1.0, 0.0, 0.0, 0.5)

# ACHTUNG: Fürs Abprallen nutzen wir move_and_collide, nicht move_and_slide!
func process_movement(delta: float):
	match current_state:
		State.REST:
			velocity = Vector2.ZERO
			move_and_slide() # Nur damit er nicht durch die Gegend rutscht
			
			state_timer -= delta
			if state_timer <= 0:
				_start_aiming()

		State.AIMING:
			velocity = Vector2.ZERO
			
			# Visuelles Zittern (Er lädt sich auf)
			anim.position = Vector2(randf_range(-4, 4), randf_range(-4, 4))
			
			# Zeichne die Ziellinie in Richtung Spieler!
			if aim_line:
				var dir = global_position.direction_to(player.global_position)
				aim_line.clear_points()
				aim_line.add_point(Vector2.ZERO)
				# Die Linie zeigt 1000 Pixel in Schussrichtung
				aim_line.add_point(to_local(global_position + dir * 1000.0)) 
			
			state_timer -= delta
			if state_timer <= 0:
				anim.position = Vector2.ZERO
				_start_dash()

		State.DASHING:
			# move_and_collide stoppt an der Wand und gibt uns Infos ZUR WAND!
			var collision = move_and_collide(velocity * delta)
			
			if collision:
				# --- DIE ABPRALL-MAGIE ---
				# get_normal() ist der Winkel der Wand. bounce() berechnet den Abprall.
				velocity = velocity.bounce(collision.get_normal())
				
				# Kamera wackeln lassen bei jedem Abpraller!
				var cam = get_tree().get_first_node_in_group("camera")
				if cam and cam.has_method("shake"):
					cam.shake(0.2, 8.0)
					
				# Boss-Farbe blitzt kurz weiß auf
				var flash_tween = create_tween()
				anim.modulate = Color(2.0, 2.0, 2.0)
				flash_tween.tween_property(anim, "modulate", Color.WHITE, 0.2)
				
				bounces_left -= 1
				if bounces_left <= 0:
					_start_rest()

# --- PHASEN-STEUERUNG ---

func _start_rest():
	current_state = State.REST
	anim.modulate = Color.WHITE
	state_timer = 2.0 # Boss muss sich 2 Sekunden ausruhen
	damage = base_boss_damage
	
	if aim_line: aim_line.hide()

func _start_aiming():
	current_state = State.AIMING
	state_timer = 1.2 # 1.2 Sekunden Vorwarnzeit für den Spieler
	
	if aim_line: aim_line.show()
	anim.modulate = Color(1.0, 0.5, 0.5) # Wird rötlich heiß

func _start_dash():
	current_state = State.DASHING
	bounces_left = max_bounces
	damage = base_boss_damage * 2.0 # Doppelter Schaden im Flug!
	anim.modulate = Color.WHITE
	
	if aim_line: aim_line.hide()
	
	# Schuss-Vektor setzen
	var dir = global_position.direction_to(player.global_position)
	velocity = dir * dash_speed
