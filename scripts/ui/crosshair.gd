class_name Crosshair extends TextureRect

func _process(_delta: float) -> void:
	visible = !UIManager.paused
	if UIManager.paused:
		return
	texture = ImageTexture.create_from_image(UIManager.get_crosshair_image(UIManager.selected_crosshair))
	position = get_viewport().get_mouse_position() + Vector2(-4, -4)
