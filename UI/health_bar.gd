class_name HealthBar extends ProgressBar

@onready var health_component: PlayerHealthComponent = $"../../../components/health"

func _ready() -> void:
	if health_component:
		max_value = health_component.max_health
		value = health_component.current_health
		set_process(true)

func _process(_delta: float) -> void:
	if health_component:
		value = health_component.current_health
