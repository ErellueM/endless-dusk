extends CanvasLayer

@export_group("Transition Settings")
@export var fade_duration: float = 0.5
@export var skip_transitions: bool = false

@onready var rect = $ColorRect

# --- DIE LÖSUNG: Ein Array als Verlauf (Stack) ---
var scene_history: Array[String] = []

func change_scene(target_path: String, instant: bool = false, is_going_back: bool = false):
	var current_scene = get_tree().current_scene
	
	# Szene NUR in den Verlauf aufnehmen, wenn wir NICHT gerade den Back-Button nutzen
	if not is_going_back and current_scene and current_scene.scene_file_path != "":
		# Verhindert, dass wir dieselbe Szene doppelt speichern
		if scene_history.is_empty() or scene_history.back() != current_scene.scene_file_path:
			scene_history.append(current_scene.scene_file_path)

	var actually_instant = instant or skip_transitions

	if actually_instant:
		rect.modulate.a = 1.0
		await get_tree().process_frame
	else:
		var tween_in = get_tree().create_tween()
		tween_in.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween_in.tween_property(rect, "modulate:a", 1.0, fade_duration)
		await tween_in.finished

	get_tree().paused = false
	var fehler_code = get_tree().change_scene_to_file(target_path)
	
	if fehler_code != OK:
		# Wenn was schiefgeht, poppt ein echtes Windows-Fenster auf!
		OS.alert("Fehler beim Laden der Szene!\nCode: " + str(fehler_code) + "\nPfad: " + target_path, "Kritischer Fehler")
	await get_tree().process_frame

	if actually_instant:
		rect.modulate.a = 0.0
	else:
		var tween_out = get_tree().create_tween()
		tween_out.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween_out.tween_property(rect, "modulate:a", 0.0, fade_duration)

func go_back(instant: bool = false):
	# Wenn wir eine Historie haben, gehen wir den Verlauf rückwärts
	if scene_history.size() > 0:
		var previous_scene = scene_history.pop_back()
		change_scene(previous_scene, instant, true) # 'true' sagt: Speichere das nicht neu im Verlauf!
	else:
		# Fallback, falls der Verlauf leer ist
		change_scene("res://main/ui/general_menu/main_menu/main_menu.tscn", instant, true)
