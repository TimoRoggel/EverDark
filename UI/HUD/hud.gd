extends Control

@onready var virus_view: Control = $VirusView
@onready var virus_bar: ProgressBar = $VirusView/VirusBar
@onready var virus_label: Label = $VirusView/VirusLabel
@onready var health_bar: HealthBar = $HealthBar

func _on_setup_virusbar(max_value: float) -> void:
	virus_bar.max_value = max_value

func _on_virus_effect(new_value: float) -> void:
	virus_bar.value = new_value

func toggle_virus_view(open: bool) -> void:
	if open:
		virus_view.show()
	else:
		virus_view.hide()

func animate_healthbar_color_change(color: Color):
	var tween = create_tween()
	tween.tween_property(health_bar, "modulate", color, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(health_bar, "modulate", Color(.7,0,0), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
func update_virusbar_color(color: Color, value: float):
	var white = Color(1, 1, 1)
	virus_bar.modulate = white.lerp(color, value)
