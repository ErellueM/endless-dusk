extends Label


func _ready():
	var version = ProjectSettings.get_setting("application/config/version")
	if version:
		text = "v" + str(version)
	else:
		text = "v0.0.0-dev"
