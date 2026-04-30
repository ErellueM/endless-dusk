extends Area2D

var damage: float = 0.0
var area_scale: float = 1.0
var duration: float = 6.0
var tick_rate: float = 1.0
var weapon_ref: Node2D = null

func _ready():
	top_level = true # Entkoppelt das Prisma vom Spieler!
	scale = Vector2(area_scale, area_scale)
	
	# Timer 1: Pulsierender Schaden
	var pulse_timer = Timer.new()
	pulse_timer.wait_time = tick_rate # Nutzt jetzt den Wert aus den Upgrades!
	pulse_timer.autostart = true
	pulse_timer.timeout.connect(_on_pulse)
	add_child(pulse_timer)
	
	# Timer 2: Lebensdauer
	var kill_timer = Timer.new()
	kill_timer.wait_time = duration
	kill_timer.one_shot = true
	kill_timer.autostart = true
	kill_timer.timeout.connect(_on_death)
	add_child(kill_timer)
	
	# Ein kleines "Aufploppen" beim Spawnen sieht gut aus
	var spawn_tween = create_tween()
	scale = Vector2.ZERO
	spawn_tween.tween_property(self, "scale", Vector2(area_scale, area_scale), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_pulse():
	var targets = get_overlapping_bodies() + get_overlapping_areas()
	var hit_someone = false
	
	for target in targets:
		if target.is_in_group("Enemygroup") and target.has_method("take_damage"):
			# Area-Schaden ohne Schadenszahlen (false)
			var actual_damage = target.take_damage(damage, false) 
			
			if weapon_ref and is_instance_valid(weapon_ref):
				weapon_ref.add_damage_stat(actual_damage)
				
			hit_someone = true
	
	# Wenn jemand getroffen wurde, pulsiert der Kristall kurz auf
	if hit_someone:
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(area_scale * 1.15, area_scale * 1.15), 0.1)
		tween.tween_property(self, "scale", Vector2(area_scale, area_scale), 0.1)

func _on_death():
	# Ausblenden und zerstören
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)
