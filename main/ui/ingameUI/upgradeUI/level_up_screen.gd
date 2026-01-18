extends CanvasLayer

@onready var card_container = $Control/VBoxContainer/CardContainer

# Wir laden die Karten-Szene
var card_scene = preload("res://main/ui/ingameUI/upgradeUI/UpgradeCard.tscn")

func _ready():
	# Wir verbinden das Signal, damit wir reagieren, wenn der GameManager uns einschaltet
	visibility_changed.connect(_on_visibility_changed)
	
	# Startzustand (optional, da GameManager eh .hide() macht)
	# visible = false 

# Diese Funktion feuert automatisch, wenn der GameManager .show() macht
func _on_visibility_changed():
	if visible:
		# Aha! Der Manager hat uns aktiviert. Jetzt Karten generieren.
		generate_cards()

# Diese Funktion baut die Karten (hieß vorher show_levelup)
func generate_cards():
	# WICHTIG: Hier KEIN visible = true oder get_tree().paused = true mehr.
	# Das ist alles schon passiert, bevor diese Funktion aufgerufen wurde.
	
	# 1. Alte Karten löschen
	for child in card_container.get_children():
		child.queue_free()
		
	# 2. Drei zufällige Optionen generieren (Dummy-Daten)
	var options = [
		{"name": "Axt", "desc": "Wirft eine Axt im hohen Bogen.", "rarity": "Common"},
		{"name": "Speed", "desc": "+10% Bewegungsgeschwindigkeit", "rarity": "Rare"},
		{"name": "Feuerball", "desc": "Verschießt einen Feuerball.", "rarity": "Legendary"}
	]
	
	# 3. Karten instanziieren
	for i in options.size():
		var option = options[i]
		var card_instance = card_scene.instantiate()
		card_container.add_child(card_instance)
		
		# Daten setzen
		card_instance.set_item_data(option["name"], option["desc"], option["rarity"])
		
		# Signal verbinden: Wenn Karte geklickt wird, rufen wir _on_upgrade_selected auf
		# .bind(option) gibt die Daten gleich mit weiter
		card_instance.selected.connect(_on_upgrade_selected.bind(option))
		
		# Animation
		card_instance.appear(i * 0.2)

# Wird aufgerufen, wenn man auf eine Karte klickt
func _on_upgrade_selected(option_data):
	print("Spieler hat gewählt: ", option_data["name"])
	
	# TODO: Hier den Effekt auf den Spieler anwenden
	# var player = get_tree().get_first_node_in_group("player")
	# player.add_upgrade(option_data)
	
	var manager = get_tree().get_first_node_in_group("Managers")
	
	if manager:
		manager.change_state(manager.GameState.PLAYING)
	else:
		print("Manager nicht gefunden!")
		visible = false
		get_tree().paused = false
