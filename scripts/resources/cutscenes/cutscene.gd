class_name Cutscene extends Resource

@export var skipable: bool = false
@export var frames: Array[CutsceneFrame] = []
@export var next_cutscene: Cutscene = null
