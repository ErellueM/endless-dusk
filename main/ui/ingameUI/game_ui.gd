extends CanvasLayer

@onready var timer_label = %TimerLabel
@onready var exp_bar = %ExpBar
@onready var health_bar = %HealthBar
@onready var upgrade_popup = $LevelUpScreen
@onready var gold_label = %GoldLabel

var time_elapsed: float = 0.0

# Wir speichern uns die Tweens, um sie stoppen zu können,
# falls der Spieler extrem schnell hintereinander XP/Schaden bekommt
var xp_tween: Tween
var health_tween: Tween
var gold_tween: Tween


func _ready():
	add_to_group("GameUI")
	
	Global.gold_changed.connect(update_gold_display)
	update_gold_display(Global.gold)
	# Zwingt die Balken, weiche Kommazahlen zu akzeptieren (verhindert das Ploppen!)
	exp_bar.step = 0.01
	health_bar.step = 0.01


func _process(delta):
	if not get_tree().paused:
		time_elapsed += delta
		update_timer_display()


func update_timer_display():
	var minutes = int(time_elapsed / 60)
	var seconds = int(time_elapsed) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]


# --- VERBINDUNGS-FUNKTIONEN ---


func _on_player_xp_changed(curr, max_val):
	exp_bar.max_value = max_val

	# Alte Animation abbrechen, falls wir gerade sehr schnell XP sammeln
	if xp_tween and xp_tween.is_running():
		xp_tween.kill()

	if curr < exp_bar.value:
		exp_bar.value = 0.0

	xp_tween = create_tween()
	xp_tween.tween_property(exp_bar, "value", curr, 0.4).set_trans(Tween.TRANS_SINE).set_ease(
		Tween.EASE_OUT
	)


func _on_player_health_changed(curr, max_val):
	health_bar.max_value = max_val

	if health_tween and health_tween.is_running():
		health_tween.kill()

	health_tween = create_tween()
	health_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	(
		health_tween
		. tween_property(health_bar, "value", curr, 0.2)
		. set_trans(Tween.TRANS_SINE)
		. set_ease(Tween.EASE_OUT)
	)

func update_gold_display(new_amount: int):
	# 1. Text aktualisieren
	gold_label.text = str(new_amount)
	
	# 2. Juice-Effekt (Ploppen)
	if gold_tween and gold_tween.is_running():
		gold_tween.kill()
	
	gold_tween = create_tween()
	gold_tween.set_parallel(true)
	
	# Skalierung: Kurz größer werden und dann zurück
	# (Dafür muss der Pivot_Offset des Labels in der Mitte liegen!)
	gold_label.pivot_offset = gold_label.size / 2
	gold_tween.tween_property(gold_label, "scale", Vector2(1.3, 1.3), 0.1).set_trans(Tween.TRANS_CUBIC)
	gold_tween.chain().tween_property(gold_label, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_SINE)
	
	# Farbe: Kurz hell aufleuchten
	gold_label.modulate = Color("#fceda6") # Dein Gold-Highlight
	gold_tween.tween_property(gold_label, "modulate", Color.WHITE, 0.3)
