extends CanvasLayer

@onready var card_container = $Control/VBoxContainer/CardContainer

# Wir laden die Karten-Szene (Pfad muss exakt stimmen!)
var card_scene = preload("res://main/ui/ingameUI/upgradeUI/UpgradeCard.tscn")

func _ready():
	# Am Anfang verstecken
	visible = false

# Input-Check für die T-Taste (Lösche diese FUnktion wenn nicht mehr am testen)
func _unhandled_input(event):
	if event.is_action_pressed("test"):
		if not visible:
			show_levelup()
		else:
			# Menü schließen beim erneuten Drücken (zum Testen)
			visible = false
			get_tree().paused = false

# Diese Funktion wird vom Signal aufgerufen
func on_level_up():
	show_levelup() # Deine existierende Logik aufrufen
	
	
# Diese Funktion baut das Menü auf und zeigt es an
func show_levelup():
	visible = true
	get_tree().paused = true
	
	# 1. Alte Karten löschen (falls noch welche da sind)
	for child in card_container.get_children():
		child.queue_free()
		
	# 2. Drei zufällige Optionen generieren (Hier Dummy-Daten zum Testen)
	var options = [
		{"name": "Axt", "desc": "Wirft eine Axt im hohen Bogen.", "rarity": "Common"},
		{"name": "Speed", "desc": "+10% Bewegungsgeschwindigkeit", "rarity": "Rare"},
		{"name": "Feuerball", "desc": "Verschießt einen Feuerball.", "rarity": "Legendary"}
	]
	
	# 3. Karten instanziieren
	for i in options.size(): # Wir nutzen i als Index (0, 1, 2)
		var option = options[i]
		var card_instance = card_scene.instantiate()
		card_container.add_child(card_instance)
		
		# Daten setzen
		card_instance.set_item_data(option["name"], option["desc"], option["rarity"])
		card_instance.selected.connect(_on_upgrade_selected.bind(option))
		
		# Der Index 'i' ist 0, 1, 2
		card_instance.appear(i * 0.2)

func _on_upgrade_selected(option_data):
	print("Spieler hat gewählt: ", option_data["name"])
	
	# Hier später: Den Effekt auf den Spieler anwenden
	# player.add_upgrade(option_data)
	
	# Menü schließen und weiter spielen
	visible = false
	get_tree().paused = false
