class_name HarvestableRunnable extends Runnable

func run(param: Dictionary) -> void:
	if !param.has("harvestable"):
		return
	var harvestable: Harvestable = DataManager.get_resource_by_id("harvestables", param["harvestable"])
	var rewards: Array[Item] = harvestable.generate_rewards()
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
		var dropped_item: DroppedItem2D = DroppedItem2D.new()
		dropped_item.item = item
		player.add_sibling(dropped_item)
		dropped_item.global_position = player.global_position
