extends PointLight2D

# Grundeinstellungen, die du im Editor für jedes Licht anpassen könntest
@export var base_energy: float = 1.0
@export var pulse_amount: float = 0.3 # Wie stark es wabert

var time_passed: float = 0.0
var pulse_speed: float = 5.0

func _ready():
	# 1. Der magische Trick gegen Synchronität:
	# Wir geben jedem Licht einen zufälligen Startzeitpunkt!
	# Dadurch fängt Kugel A beim hellsten Punkt an, Kugel B beim dunkelsten etc.
	time_passed = randf_range(0.0, 100.0)
	
	# 2. Wir machen die Wabern-Geschwindigkeit bei jeder Kugel GANZ LEICHT anders (z.B. zwischen 4.0 und 6.0)
	pulse_speed = randf_range(4.0, 6.0)
	
	# 3. Kleine Variation in der Grundhelligkeit (manche sind etwas heller, manche dunkler)
	base_energy = base_energy * randf_range(0.8, 1.2)

func _process(delta):
	time_passed += delta
	# Die Mathe dahinter: Grundhelligkeit + (Sinus-Welle * Stärke)
	energy = base_energy + sin(time_passed * pulse_speed) * pulse_amount
