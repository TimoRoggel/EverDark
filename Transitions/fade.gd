extends ColorRect

var duration: float 

func _ready() -> void:
	color = Color(0, 0, 0, 0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func transition_in(target_scene: String):
	var tween = create_tween()
	tween.tween_property(self, "color", Color(0, 0, 0, 1), duration / 2)
	tween.tween_callback(func(): SceneTransitionController.transition_half_completed.emit(target_scene))
	
	tween.tween_property(self, "color", Color(0, 0, 0, 0), duration / 2)
	tween.tween_callback(func(): SceneTransitionController.transition_completed.emit())
	
