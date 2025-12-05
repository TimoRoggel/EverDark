class_name ItemPickupRunnable extends Runnable

func run(param: Dictionary) -> void:
	if !param.has("item"):
		return
	param["self"].active = false
	var pickup_sound: RandomAudioStreamPlayer2D = GameManager.create_audio_player(&"SFX", [preload("uid://cw1m382crj73o"), preload("uid://baih8kycsvoir")], param["self"])
	pickup_sound.play_randomized()
	var remainder: int = param["controller"].inventory.add(param["item"], param.get("quantity", 1))
	param["controller"].animation.play("pickdrop")
	if remainder > 0:
		param["self"].amount = remainder
		param["self"].global_position = param["controller"].global_position
		param["self"].active = true
	else:
		param["self"].visible = false
		await pickup_sound.finished
		param["self"].queue_free()

func can_run(param: Dictionary) -> bool:
	if !param.has("item"):
		return false
	if !param["controller"].inventory:
		return false
	return param["controller"].inventory.available_space(param["item"]) > 0
