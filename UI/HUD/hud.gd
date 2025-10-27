extends Control

@onready var virus_view: Control = $VirusView
@onready var virus_bar: ProgressBar = $VirusView/VirusBar
@onready var virus_label: Label = $VirusView/VirusLabel

func _on_setup_virusbar( max: float):
	virus_bar.max_value = max

func _on_virus_effect(new_value):
	virus_bar.value = new_value

func toggle_virus_view(open: bool):
	if open:
		virus_view.show()
	else:
		virus_view.hide()
