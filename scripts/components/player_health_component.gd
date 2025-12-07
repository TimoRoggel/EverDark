class_name PlayerHealthComponent extends HealthComponent

func _enter() -> void:
	persistent = true
	screen_shake_amount = 1.0
	super()
	SaveSystem.track("player_health", get_health, set_health, max_health)

func death() -> void:
	if controller.death:
		controller.death.entity_died()
	if death_player:
		death_player.play_randomized()

func get_health() -> float:
	return current_health

func set_health(health: float) -> void:
	current_health = health
