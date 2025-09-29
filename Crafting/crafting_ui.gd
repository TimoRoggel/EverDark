class_name Crafting_UI
extends PanelContainer

const INVENTORY_SLOT: PackedScene = preload("uid://chgdmhkgaavft")

@onready var tree: Tree = %Tree
@onready var title_label: Label = %TitleLabel
@onready var grid_container: GridContainer = %GridContainer
@onready var item_texture: TextureRect = %ItemTexture
@onready var craft_button: Button = %CraftButton 

var recipe_material_dict: Dictionary[Item, int] = {}
var inventory: InventoryComponent = null
var current_recipe: Recipe = null

func _ready() -> void:
	build_recipe_tree()
	craft_button.pressed.connect(_on_CraftButton_pressed)

func build_recipe_tree() -> void:
	tree.hide_root = true
	var tree_root: TreeItem = tree.create_item()

	for recipe in DataManager.resources["recipes"]:
		var new_recipe_slot: TreeItem = tree.create_item(tree_root)
		new_recipe_slot.set_icon(0, recipe.rewards[0].icon)
		new_recipe_slot.set_text(0, recipe.rewards[0].display_name)
		if tree.get_selected() == null:
			tree.set_selected(new_recipe_slot, 0)

func _on_tree_cell_selected() -> void:
	var cell_recipe_name: String = tree.get_selected().get_text(0)

	for recipe in DataManager.resources["recipes"]:
		if recipe.rewards[0].display_name == cell_recipe_name:
			build_recipe_material_window(recipe)
			return

func build_recipe_material_window(selected_recipe: Recipe) -> void:
	current_recipe = selected_recipe
	clean_material_window()
	title_label.text = selected_recipe.rewards[0].display_name
	item_texture.texture = selected_recipe.rewards[0].icon

	#Cost
	for recipe_material: Item in selected_recipe.costs:
		if recipe_material_dict.has(recipe_material):
			recipe_material_dict[recipe_material] += 1
		else:
			recipe_material_dict[recipe_material] = 1

	#Amounth
	for recipe_material: Item in recipe_material_dict.keys():
		var required_amount: int = recipe_material_dict[recipe_material]
		var current_amount: int = inventory.count(recipe_material.id) if inventory else 0

		var slot: InventorySlotCrafting = INVENTORY_SLOT.instantiate()
		grid_container.add_child(slot)
		slot.set_item_data(recipe_material, current_amount, required_amount)

func clean_material_window() -> void:
	recipe_material_dict.clear()
	for child in grid_container.get_children():
		child.queue_free()

func _on_CraftButton_pressed() -> void:
	if not current_recipe or not inventory:
		return

	var required_materials: Dictionary[int, int] = {}
	for item_id in current_recipe.cost_ids:
		if required_materials.has(item_id):
			required_materials[item_id] += 1
		else:
			required_materials[item_id] = 1

	for item_id in required_materials.keys():
		var needed = required_materials[item_id]
		if not inventory.has(item_id, needed):
			#printerr("No inventory found")
			return

	for item_id in required_materials.keys():
		var needed = required_materials[item_id]
		inventory.remove(item_id, needed)

	for reward_id in current_recipe.reward_ids:
		inventory.add(reward_id, 1)

	build_recipe_material_window(current_recipe)
	#printerr("Crafting is bugged")
