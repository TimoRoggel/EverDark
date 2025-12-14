extends NinePatchRect

@onready var description: Label = %description
@onready var check: CheckBox = %check
@onready var complete_player: AudioStreamPlayer = %complete_player

var shown: bool = true
var override: bool = true

func _ready() -> void:
	GameManager.objective_finished.connect(update_objective)
	override = true
	await show_current_objective()
	override = false

func _physics_process(_delta: float) -> void:
	if override:
		return
	if get_rect().has_point(get_global_mouse_position()):
		if !shown:
			show_tween()
	else:
		if shown:
			hide_tween()

func update_objective() -> void:
	override = true
	await close_current_objective()
	await get_tree().create_timer(0.5, false).timeout
	await show_current_objective()
	override = false

func close_current_objective() -> void:
	complete_player.play()
	check.button_pressed = true
	await show_tween()
	await get_tree().create_timer(0.5, false).timeout
	hide_tween()
	await tween_to(645.0)

func show_current_objective() -> void:
	check.button_pressed = false
	description.text = GameManager.OBJECTIVE_DESCRIPTIONS[GameManager.OBJECTIVE_ORDER[GameManager.current_objective]]
	show_tween()
	await tween_to(345.0)
	await get_tree().create_timer(1.5, false).timeout
	await hide_tween()

func show_tween() -> void:
	shown = true
	await tween_visibility(0.75)

func hide_tween() -> void:
	shown = false
	await tween_visibility(0.25)

func tween_to(target: float) -> void:
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	tween.tween_property(self, "global_position:x", target, 0.5)
	tween.play()
	await tween.finished

func tween_visibility(target: float) -> void:
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "modulate:a", target, 0.2)
	tween.play()
	await tween.finished
