class_name HarvestableRunnable extends Runnable

func run(param: Dictionary) -> void:
	if !param.has("harvestable"):
		return
	var pickup_sound: RandomAudioStreamPlayer2D = GameManager.create_audio_player(&"SFX", [preload("uid://isfothg2nb5m"), preload("uid://hq6hainfcvp8"), preload("uid://cp2ah8nknrf8t"), preload("uid://tm0cgedjn7uk"), preload("uid://bd2n4y3ua31mn"), preload("uid://cdddkrf2hox1c")], param["self"])
	pickup_sound.play_randomized()
	var harvestable: Harvestable = DataManager.get_resource_by_id("harvestables", param["harvestable"])
	var rewards: Array[Item] = harvestable.generate_rewards()
	param["controller"].animation.play("pickdrop")
	for i: Item in rewards:
		give_item(param["controller"], i)
	param["self"].deplete()

func can_run(param: Dictionary) -> bool:
	if !param.has("harvestable"):
		return false
	if param["self"].is_depleted():
		return false
	if !param["controller"].inventory:
		return false
	return !param["controller"].inventory.is_full()

func give_item(player: PlayerController, item: Item) -> void:
	var remainder: int = player.inventory.add(item.id, 1)
	if remainder > 0:
		DroppedItem2D.drop(item.id, remainder, player.global_position)
