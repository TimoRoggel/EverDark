class_name AmbiencePlayer extends AudioStreamPlayer

## How frequent an ambient sound should be played in seconds.
@export_range(0.0, 600.0, 0.0001) var frequency: float = 50.0
## Randomness of the sound playing.
@export_range(0.0, 1.0, 0.0001) var randomness: float = 0.0

func _ready() -> void:
	ambience_loop()

func ambience_loop() -> void:
	await get_tree().create_timer(_get_random_time(), false).timeout
	play()
	await finished
	ambience_loop()

func _get_random_time() -> float:
	return frequency * randf_range(1.0 - randomness * 0.5, 1.0 + randomness * 0.5)
