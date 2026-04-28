extends BaseEnemy
class_name VoidPullerBoss

@export_group("Void Settings")
@export var pull_strength: float = 60.0 # Wie stark er den Spieler anzieht

@onready var gravity_zone = $GravityZone

func _ready():
	is_miniboss = true
	super._ready()
	
	# Wenn dein Schwarzes Loch sich drehen soll:
	var rotate_tween = create_tween().set_loops()
	rotate_tween.tween_property(anim, "rotation", TAU, 4.0).from(0.0)

# Wir nutzen _physics_process, um den Sog jeden Frame anzuwenden
func _physics_process(delta):
	# Wichtig: Den BaseEnemy-Code weiterhin ausführen (für Farbe & Bewegung)
	super._physics_process(delta) 
	
	if is_dead or not player:
		return
		
	# --- DIE SCHWARZE-LOCH-MECHANIK ---
	var targets_in_zone = gravity_zone.get_overlapping_bodies()
	
	for t in targets_in_zone:
		if t.is_in_group("player"):
			# 1. Richtung vom Spieler ZUM Boss berechnen
			var pull_direction = t.global_position.direction_to(global_position)
			
			# 2. Den Spieler physikalisch heranziehen
			# Das fühlt sich an wie ein Verlangsamungs-Effekt, wenn man wegläuft!
			t.global_position += pull_direction * pull_strength * delta
