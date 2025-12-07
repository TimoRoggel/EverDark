class_name CutsceneFrame extends Resource

@export_group("Info")
@export var image: Texture2D = null
@export var size: Vector2 = Vector2(640, 360)
@export var centered: bool = true
@export var transition: CutsceneTransition = null
@export var sound: AudioStream = null
@export_group("Movement")
@export var start_position: Vector2 = Vector2.ZERO
@export var end_position: Vector2 = Vector2.ZERO
@export var start_zoom: float = 1.0
@export var end_zoom: float = 1.0
@export var duration: float = 1.0
