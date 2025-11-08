class_name PlayerHealthComponent extends HealthComponent

func _enter() -> void:
	persistent = true
	screen_shake_amount = 1.0
	super()

func death() -> void:
	if controller.death:
		controller.death.entity_died()
	if death_player:
		death_player.play_randomized()
