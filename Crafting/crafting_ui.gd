class_name Crafting_UI
extends PanelContainer

const INVENTORY_SLOT: PackedScene = preload("uid://chgdmhkgaavft")

@onready var tree : Tree = %Tree
@onready var title_label : Label = %TitleLabel
@onready var grid_container : GridContainer = %GridContainer
@onready var item_texture : TextureRect = %ItemTexture

var recipe_material_dict : Dictionary[Item, int] = {}

func _ready() -> void:
	build_recipe_tree()

func build_recipe_tree() -> void:
	tree.hide_root = true
	var tree_root : TreeItem = tree.create_item()
	
	for recipe in DataManager.resources["recipes"]:
		var new_recipe_slot : TreeItem = tree.create_item(tree_root)
		new_recipe_slot.set_icon(0, recipe.rewards[0].icon)
		new_recipe_slot.set_text(0, recipe.rewards[0].display_name)
		if tree.get_selected() == null:
			tree.set_selected(new_recipe_slot, 0)

func _on_tree_cell_selected() -> void:
	var cell_recipe_name : String = tree.get_selected().get_text(0)
	
	for recipe in DataManager.resources["recipes"]:
		if recipe.rewards[0].display_name == cell_recipe_name:
			build_recipe_material_window(recipe)
			return

func build_recipe_material_window(selected_recipe : Recipe) -> void:
	clean_material_window()
	title_label.text = selected_recipe.rewards[0].display_name
	item_texture.texture = selected_recipe.rewards[0].icon
	
	for recipe_material: Item in selected_recipe.costs:
		if recipe_material_dict.has(recipe_material):
			recipe_material_dict[recipe_material] += 1
		else:
			recipe_material_dict[recipe_material] = 1
		var slot: InventorySlotCrafting = INVENTORY_SLOT.instantiate()
		grid_container.add_child(slot)
		slot.set_item_data(recipe_material)

func clean_material_window() -> void:
	recipe_material_dict.clear()
	
	for child in grid_container.get_children():
		child.queue_free()
