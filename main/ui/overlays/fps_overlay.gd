extends CanvasLayer

@onready var label = $Label

func _ready():
	_on_show_fps_changed(SettingsManager.show_fps)
	SettingsManager.show_fps_changed.connect(_on_show_fps_changed)

func _on_show_fps_changed(is_visible: bool):
	label.visible = is_visible
	set_process(is_visible)

func _process(_delta):
	label.text = str(int(Engine.get_frames_per_second()))
