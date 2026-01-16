extends Control

const VIRUS_COLOR_BASE: Color = Color(0.637, 0.514, 1.0, 1.0)
const VIRUS_COLOR_TARGET: Color = Color(0.486, 0.003, 0.993, 1.0)

@onready var virus_view: Control = $VirusView
@onready var virus_bar: ProgressBar = $VirusView/VirusBar
@onready var health_bar: HealthBar = $HealthBar

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	GameManager.player.death.respawning.connect(func() -> void: update_virusbar_color(0.0))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_ui"):
		get_parent().visible = !get_parent().visible

func _on_setup_virusbar(max_value: float) -> void:
	virus_bar.max_value = max_value

func animate_healthbar_color_change(color: Color):
	var tween = create_tween()
	tween.tween_property(health_bar, "modulate", color, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(health_bar, "modulate", Color(.7,0,0), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
func update_virusbar_color(value: float):
	virus_bar.value = value * virus_bar.max_value
	virus_bar.self_modulate = VIRUS_COLOR_BASE.lerp(VIRUS_COLOR_TARGET, value)
	virus_bar.modulate.a = value * 0.5
