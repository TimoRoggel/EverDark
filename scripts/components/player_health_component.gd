class_name PlayerHealthComponent extends HealthComponent

func _enter() -> void:
	persistent = true
	screen_shake_amount = 1.0
	super()

func death() -> void:
	print("died, resetting health to max")
	current_health = max_health
