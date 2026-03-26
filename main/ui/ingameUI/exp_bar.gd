extends TextureProgressBar # <-- Stelle sicher, dass hier ProgressBar steht, wenn es deine XP-Leiste ist

var current_time: float = 0.0

func _process(delta):
	# Die Zeit läuft nur weiter, wenn das Spiel NICHT pausiert ist
	current_time += delta
	# Wir füttern den Shader mit der Zeit
	if material is ShaderMaterial:
		(material as ShaderMaterial).set_shader_parameter("custom_time", current_time)

# --- NEU: Die Funktion für das weiche Auffüllen ---
func update_xp_bar(new_current_xp: float, new_max_xp: float):
	max_value = new_max_xp
	
	# Falls ein Level-Up stattfand (die neuen XP sind kleiner als das, was der Balken gerade anzeigt)
	if new_current_xp < value:
		value = 0.0
		
	# Die weiche Tween-Animation (0.4 Sekunden Dauer)
	var tween = create_tween()
	tween.tween_property(self, "value", new_current_xp, 0.4)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
