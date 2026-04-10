extends CanvasLayer

@export_group("Transition Settings")
@export var fade_duration: float = 0.5
@export var skip_transitions: bool = false

@onready var rect = $ColorRect
var previous_scene_path: String = ""


func change_scene(target_path: String, instant: bool = false):
	var current_scene = get_tree().current_scene
	if current_scene and current_scene.scene_file_path != "":
		previous_scene_path = current_scene.scene_file_path

	# Prüfen, ob eine der beiden Bedingungen (lokal oder global) den Fade überspringt
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
	get_tree().change_scene_to_file(target_path)

	await get_tree().process_frame

	if actually_instant:
		rect.modulate.a = 0.0
	else:
		var tween_out = get_tree().create_tween()
		tween_out.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween_out.tween_property(rect, "modulate:a", 0.0, fade_duration)


func go_back(instant: bool = false):
	if previous_scene_path != "":
		change_scene(previous_scene_path, instant)
	else:
		change_scene("res://main/ui/general_menu/main_menu/main_menu.tscn", instant)
