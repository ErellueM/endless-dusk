extends CanvasLayer

@onready var timer_label = %TimerLabel
@onready var exp_bar = %ExpBar
@onready var health_bar = %HealthBar
@onready var upgrade_popup = $LevelUpScreen 

var time_elapsed: float = 0.0

func _ready():
	add_to_group("GameUI")
	pass

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
	exp_bar.value = curr
	
func _on_player_health_changed(curr, max_val):
	health_bar.max_value = max_val
	health_bar.value = curr
