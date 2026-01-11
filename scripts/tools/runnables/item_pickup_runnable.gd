class_name ItemPickupRunnable extends Runnable

func run(param: Dictionary) -> void:
	if !param.has("item"):
		return
	param["self"].active = false
	var pickup_sound: RandomAudioStreamPlayer2D = GameManager.create_audio_player(&"SFX", [preload("uid://cw1m382crj73o"), preload("uid://baih8kycsvoir")], param["self"])
	pickup_sound.play_randomized()
	param["controller"].animation.play("pickdrop")
	param["self"].scale_to(0.0)
	await move_to(param["self"], param["controller"])
	var remainder: int = param["controller"].inventory.add(param["item"], param.get("quantity", 1))
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

func move_to(item: DroppedItem2D, target: Node2D) -> void:
	var tween: Tween = item.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(item, "global_position", target.global_position, 0.2)
	tween.play()
	await tween.finished
