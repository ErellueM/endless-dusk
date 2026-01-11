extends CanvasLayer

@onready var timer_label = %TimerLabel
@onready var exp_bar = %ExpBar # Deine TextureProgressBar (Unique Name!)
@onready var upgrade_popup = $LevelUpScreen # Pfad zur Popup-Node in dieser Szene

var time_elapsed: float = 0.0

func _process(delta):
	# Timer Logik (hast du schon perfekt)
	if not get_tree().paused:
		time_elapsed += delta
		update_timer_display()

func update_timer_display():
	# (Dein bestehender Timer Code)
	var minutes = int(time_elapsed / 60)
	var seconds = int(time_elapsed) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]

# --- VERBINDUNGS-FUNKTIONEN ---

func _on_player_xp_changed(curr, max_val):
	# Balken updaten
	exp_bar.max_value = max_val
	exp_bar.value = curr

func _on_player_leveled_up():
	# Upgrade Menü öffnen
	upgrade_popup.on_level_up()
