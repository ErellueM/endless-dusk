extends Button

# Wir holen uns das Label, das im Button steckt
# (Wir gehen davon aus, dass es das erste Kind ist oder "Label" heißt)
@onready var label = $Label

# Farben für die Zustände (kannst du im Inspector einstellen!)
@export var color_normal: Color = Color(1, 1, 1, 1)
@export var color_hover: Color = Color(2, 2, 2, 1) 
@export var color_pressed: Color = Color(0.5, 0.5, 0.5, 1) # Grau/Dunkel

# Versatz beim Drücken (für den "Klick"-Effekt)
@export var click_offset_y: int = 2 

func _ready():
	# Wir stellen sicher, dass die Farbe am Anfang stimmt
	_update_color(color_normal)
	
	# Wir verbinden die Signale des Buttons mit unseren Funktionen
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

# --- Die Reaktionen ---

func _on_mouse_entered():
	# Maus ist drauf -> Farbe ändern & Sound abspielen (optional)
	_update_color(color_hover)
	# Optional: Kleiner "Hopser" nach rechts
	# label.position.x += 2 

func _on_mouse_exited():
	# Maus weg -> Zurück zu Weiß
	_update_color(color_normal)
	# label.position.x -= 2

func _on_button_down():
	# Gedrückt halten -> Farbe ändern & Text nach unten schieben
	_update_color(color_pressed)
	label.position.y += click_offset_y

func _on_button_up():
	# Loslassen -> Zurück zum Hover-Zustand (weil Maus ja noch drauf ist)
	_update_color(color_hover)
	label.position.y -= click_offset_y

# Hilfsfunktion, um die Farbe sauber zu setzen
func _update_color(new_color: Color):
	# Wir färben das Label ein (Modulate beeinflusst auch den Schatten leicht, 
	# aber meistens sieht das gut aus. Falls nicht, ändern wir label_settings)
	label.modulate = new_color
