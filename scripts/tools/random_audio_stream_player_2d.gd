class_name RandomAudioStreamPlayer2D extends AudioStreamPlayer2D

@export var samples: Array[AudioStream] = []
@export_range(0.0, 1.0, 0.001) var volume_range: float = 0.05
@export_range(0.0, 1.0, 0.001) var pitch_range: float = 0.05
@export var free_on_completion: bool = false

var base_volume: float = volume_db
var base_pitch: float = pitch_scale

func _ready() -> void:
	if autoplay:
		play_randomized()

func play_randomized(from_position: float = 0.0) -> void:
	if samples.size() < 1:
		return
	stream = samples.pick_random()
	volume_db = GameManager.get_randomized_value(base_volume, volume_range)
	pitch_scale = GameManager.get_randomized_value(base_pitch, pitch_range)
	play(from_position)
	if free_on_completion:
		await finished
		queue_free()
