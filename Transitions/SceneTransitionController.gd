extends Node

signal transition_half_completed(target_scene: String)
signal transition_completed 

var current_transition: Node = null 
var is_transitioning: bool = false 

func change_scene(target_scene: String, transition_type: String = "fade_layer", duration: float = 1.0):
	if is_transitioning:
		return
		
	is_transitioning = true
	
	var transition_scene: Node = null 
	
	match transition_type:
		"fade_layer":
			transition_scene = load("res://Transitions/fade_layer.tscn").instantiate()
	
	get_tree().root.add_child(transition_scene)
	current_transition = transition_scene
	
	var fade_rect = transition_scene.get_node("Fade")
	fade_rect.duration = duration
	fade_rect.transition_in(target_scene)
	
	transition_half_completed.connect(_on_transition_half_completed)
	transition_completed.connect(_on_transition_completed)

func _on_transition_half_completed(target_scene: String):
	get_tree().change_scene_to_file(target_scene)

func _on_transition_completed():
	if current_transition:
		if current_transition.get_parent():
			current_transition.get_parent().remove_child(current_transition)
		current_transition.queue_free()
		current_transition = null 
		
		transition_half_completed.disconnect(_on_transition_half_completed)
		transition_completed.disconnect(_on_transition_completed)
	
	is_transitioning = false
