extends Node

var overlay: CanvasLayer = CanvasLayer.new()
var frame_texture: TextureRect = TextureRect.new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.layer = 2
	add_child(overlay)
	overlay.add_child(frame_texture)
	overlay.visible = false

func play(cutscene: Cutscene) -> void:
	overlay.visible = true
	# Pause
	var previous_paused: bool = get_tree().paused
	get_tree().paused = true
	# Show frames
	for frame: CutsceneFrame in cutscene.frames:
		if await show_cutscene_frame(frame, cutscene.skipable):
			break
	# Continue / next cutscene
	if cutscene.next_cutscene:
		play(cutscene.next_cutscene)
	else:
		get_tree().paused = previous_paused
		overlay.visible = false

func show_cutscene_frame(frame: CutsceneFrame, can_skip: bool = false) -> bool:
	# Initialize settings
	frame_texture.texture = frame.image
	frame_texture.position = frame.start_position
	frame_texture.scale = Vector2.ONE * frame.start_zoom
	# Create animation
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(frame_texture, "position", frame.end_position, frame.duration)
	tween.tween_property(frame_texture, "scale", Vector2.ONE * frame.end_zoom, frame.duration)
	tween.play()
	# Check for skip
	while tween.is_running():
		await get_tree().process_frame
		if can_skip && Input.is_action_just_pressed("debug"):
			tween.stop()
			return true
	return false
