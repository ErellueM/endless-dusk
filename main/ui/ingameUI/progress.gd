extends TextureRect

var current_time: float = 0.0

func _process(delta):
	# Die Zeit läuft nur weiter, wenn das Spiel NICHT pausiert ist,
	# weil _process im Pause-Modus automatisch stoppt (Standard-Einstellung).
	current_time += delta
	
	# Wir füttern den Shader mit der Zeit
	(material as ShaderMaterial).set_shader_parameter("custom_time", current_time)
