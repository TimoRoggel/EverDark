class_name HealthBar extends ProgressBar

var health_component: PlayerHealthComponent = null

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	health_component = GameManager.player.health
	if health_component:
		max_value = health_component.max_health
		value = health_component.current_health
		set_process(true)

func _process(_delta: float) -> void:
	if health_component:
		value = health_component.current_health
