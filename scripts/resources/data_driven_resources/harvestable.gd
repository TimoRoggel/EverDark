class_name Harvestable extends DataDrivenResource

@export var harvestable_name: String = ""
@export var ready_texture: Texture2D = null
@export var depleted_texture: Texture2D = null
@export var reward_ids: PackedInt32Array = []
@export var reward_odds: PackedInt32Array = []
@export var min_recover_time: int = 0
@export var max_recover_time: int = 0

var rewards: Array[Item] = []

static func from_data(data: Dictionary) -> Harvestable:
	var harvestable: Harvestable = Harvestable.new()
	
	harvestable.id = data["id"]
	harvestable.harvestable_name = data["name"]
	harvestable.ready_texture = load(data["ready_texture"])
	harvestable.depleted_texture = load(data["depleted_texture"])
	harvestable.reward_ids = data["rewards"]
	harvestable.reward_odds = data["reward_odds"]
	harvestable.min_recover_time = data["min_recover_time"]
	harvestable.max_recover_time = data["max_recover_time"]
	
	harvestable.rewards = harvestable.get_rewards()
	
	return harvestable

func get_rewards() -> Array[Item]:
	var reward_array: Array[Item] = []
	for i: int in reward_ids:
		reward_array.append(DataManager.get_resource_by_id("items", i))
	return reward_array

func generate_rewards() -> Array[Item]:
	var reward_array: Array[Item] = []
	for i: int in reward_odds.size():
		var r: int = randi_range(0, 100)
		if reward_odds[i] < r:
			continue
		reward_array.append(rewards[i])
	return reward_array
