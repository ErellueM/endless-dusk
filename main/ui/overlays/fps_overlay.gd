extends CanvasLayer

@onready var label = $Label

func _process(_delta):
	if "show_fps" in SettingsManager and SettingsManager.show_fps:
		label.show()
		label.text =  str(int(Engine.get_frames_per_second())) #"FPS: " +
	else:
		label.hide()
