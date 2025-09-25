class_name Recipe extends Resource

@export var id: int = -1
@export var recipe_name: String = ""
@export var reward_ids: PackedInt32Array = []
@export var cost_ids: PackedInt32Array = []

var rewards: Array[Item] = []
var costs: Array[Item] = []

static func from_data(data: Dictionary) -> Recipe:
	var recipe: Recipe = Recipe.new()
	recipe.id = data["id"]
	recipe.recipe_name = data["name"]
	recipe.reward_ids = data["rewards"]
	recipe.cost_ids = data["costs"]
	
	recipe.rewards = recipe.get_rewards()
	recipe.costs = recipe.get_costs()
	
	return recipe

func get_rewards() -> Array[Item]:
	var reward_array: Array[Item] = []
	for i: int in reward_ids:
		reward_array.append(DataManager.get_resource_by_id("items", i))
	return reward_array

func get_costs() -> Array[Item]:
	var costs_array: Array[Item] = []
	for i: int in cost_ids:
		costs_array.append(DataManager.get_resource_by_id("items", i))
	return costs_array
