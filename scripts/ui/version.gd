class_name Version extends Label

func _ready() -> void:
	text = ProjectSettings.get_setting("application/config/version")
