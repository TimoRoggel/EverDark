extends Control

func _ready() -> void:

	visible = GameManager.show_controls_overlay
	
	if not GameManager.is_connected("controls_visibility_changed", _on_visibility_changed):
		GameManager.controls_visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed(new_state: bool) -> void:
	visible = new_state
