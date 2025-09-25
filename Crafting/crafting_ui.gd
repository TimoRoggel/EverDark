class_name Crafting_UI
extends PanelContainer

@export var inventory_slot_crafting : PackedScene = null
@export var recipe_array : Array[ItemRecipe] = []

@onready var tree : Tree = %Tree
@onready var title_label : Label = %TitleLabel
@onready var grid_container : GridContainer = %GridContainer
@onready var item_texture : TextureRect = %ItemTexture

var recipe_material_dict : Dictionary = {}

func _ready() -> void:
	build_recipe_tree()


func build_recipe_tree() -> void:
	tree.hide_root = true
	var tree_root : TreeItem = tree.create_item()
	
	for recipe in recipe_array:
		var new_recipe_slot : TreeItem = tree.create_item(tree_root)
		new_recipe_slot.set_icon(0, recipe.recipe_final_item.item_texture)
		new_recipe_slot.set_text(0, recipe.recipe_final_item.item_name)


func _on_tree_cell_selected() -> void:
	var cell_recipe_name : String = tree.get_selected().get_text(0)
	
	for recipe in recipe_array:
		if recipe.recipe_final_item.item_name == cell_recipe_name:
			build_recipe_material_window(recipe)
			return

func build_recipe_material_window(selected_recipe : ItemRecipe) -> void:
	clean_material_window()
	title_label.text = selected_recipe.recipe_final_item.item_name
	item_texture.texture = selected_recipe.recipe_final_item.item_texture
	
	for recipe_material in selected_recipe.recipe_material_array:
		if recipe_material_dict.has(recipe_material):
			recipe_material_dict[recipe_material] += 1
		else:
			recipe_material_dict[recipe_material] = 1
			
func clean_material_window() -> void:
	recipe_material_dict.clear()
	
	for child in grid_container.get_children():
		child.queue_free()
