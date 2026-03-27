extends Area2D

@export var speed: float = 250.0
@export var damage: float = 15.0

# Diese Richtung wird vom Pestdoktor beim Spawnen gesetzt!
var direction: Vector2 = Vector2.ZERO 

func _ready():
	# Wir verbinden das Signal, wenn die Kugel etwas trifft
	body_entered.connect(_on_body_entered)
	
	# Müllabfuhr: Wenn die Kugel den Bildschirm verlässt, löschen wir sie, 
	# sonst fliegt sie unendlich weiter und das Spiel fängt irgendwann an zu laggen!
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)

func _physics_process(delta):
	# Die Kugel fliegt stur in ihre Richtung
	position += direction * speed * delta
	
	# Wenn du eine längliche Kugel hast, dreht sie sich hiermit in Flugrichtung:
	rotation = direction.angle()

func _on_body_entered(body: Node2D):
	# Prüfen, ob wir den Spieler getroffen haben
	if body.is_in_group("player"):
		if body.has_method("take_damage_typed"):
			# true steht hier für is_dot (Damage over Time) - du kannst es auch false lassen
			# Color(0, 1, 0) ist grüner Text für den Gift-Schaden!
			body.take_damage_typed(damage, false, Color(0.2, 1.0, 0.2))
		
		# Kugel zerstören, nachdem sie den Spieler getroffen hat
		queue_free()
