extends Node

var overlay: CanvasLayer = CanvasLayer.new()
var frame_texture: TextureRect = null
var cutscene_background_music: AudioStreamPlayer = null
var cutscene_sound_player: AudioStreamPlayer = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.layer = 2
	add_child(overlay)
	overlay.visible = false
	cutscene_background_music = AudioStreamPlayer.new()
	cutscene_background_music.bus = &"Music"
	add_child(cutscene_background_music)
	cutscene_sound_player = AudioStreamPlayer.new()
	cutscene_sound_player.bus = &"SFX"
	add_child(cutscene_sound_player)

func _setup_frame(frame: CutsceneFrame) -> TextureRect:
	var text_rect: TextureRect = TextureRect.new()
	overlay.add_child(text_rect)
	# Initialize settings
	text_rect.texture = frame.image
	text_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	text_rect.position = frame.start_position
	text_rect.scale = Vector2.ONE * frame.start_zoom
	text_rect.size = frame.size
	if frame.centered:
		text_rect.pivot_offset = text_rect.size / 2.0
	return text_rect

func play(cutscene: Cutscene) -> void:
	overlay.visible = true
	if cutscene.background_audio:
		cutscene_background_music.stream = cutscene.background_audio
		cutscene_background_music.play()
	# Pause
	var previous_paused: bool = get_tree().paused
	get_tree().paused = true
	# Show frames
	for i: int in cutscene.frames.size():
		var frame: CutsceneFrame = cutscene.frames[i]
		if await show_cutscene_frame(frame, i, cutscene):
			break
	cutscene_background_music.stop()
	# Continue / next cutscene
	if cutscene.next_cutscene:
		play(cutscene.next_cutscene)
	else:
		get_tree().paused = previous_paused
		overlay.visible = false

func show_cutscene_frame(frame: CutsceneFrame, index: int, cutscene: Cutscene) -> bool:
	frame_texture = _setup_frame(frame)
	# Create animation
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(frame_texture, "position", frame.end_position, frame.duration)
	tween.tween_property(frame_texture, "scale", Vector2.ONE * frame.end_zoom, frame.duration)
	tween.play()
	# Sounds
	if frame.sound:
		cutscene_sound_player.stream = frame.sound
		cutscene_sound_player.play()
	# Check for skip
	while tween.is_running():
		await get_tree().process_frame
		if cutscene.skipable && Input.is_action_just_pressed("skip"):
			tween.stop()
			return true
	# Transition
	if frame.transition:
		# Find next texture and underlay it
		var under_texture: TextureRect = null
		if index + 1 < cutscene.frames.size():
			under_texture = _setup_frame(cutscene.frames[index + 1])
		elif cutscene.next_cutscene && cutscene.next_cutscene.frames.size() > 0:
			under_texture = _setup_frame(cutscene.next_cutscene.frames[0])
		if under_texture:
			overlay.move_child(under_texture, 0)
		# Setup transition
		var trans_tween: Tween = create_tween().set_trans(frame.transition.transition_type).set_ease(frame.transition.easing)
		trans_tween.tween_property(frame_texture, "modulate:a", 0.0, frame.transition.duration)
		trans_tween.play()
		# Check for skip
		while trans_tween.is_running():
			await get_tree().process_frame
			if cutscene.skipable && Input.is_action_just_pressed("skip"):
				trans_tween.stop()
				if under_texture:
					under_texture.queue_free()
				return true
		if under_texture:
			under_texture.queue_free()
	return false
