class_name VirusBar extends ProgressBar

@onready var virus_label: Label = $"../VirusLabel"

var everdark_damage_component: EverdarkDamageComponent

func _ready() -> void:
	pass
		
func activate(everdark_damage: EverdarkDamageComponent):
	everdark_damage_component = everdark_damage
	self.show()
	virus_label.show()

func deactivate():
	self.hide()
	virus_label.hide()
