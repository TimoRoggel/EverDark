extends Control

@onready var virus_view: Control = $VirusView
@onready var virus_bar: ProgressBar = $VirusView/VirusBar
@onready var health_bar: HealthBar = $HealthBar

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	GameManager.player.death.respawning.connect(func() -> void: update_virusbar_color(Color.WHITE, 0.0))

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
	var white = Color(0.637, 0.514, 1.0, 1.0)  
	virus_bar.self_modulate = white.lerp(color, value)
	virus_bar.modulate.a = value * 0.5
