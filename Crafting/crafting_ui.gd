class_name Crafting_UI
extends PanelContainer

signal close_requested

const INVENTORY_SLOT: PackedScene = preload("uid://chgdmhkgaavft")

@onready var tree: Tree = %Tree
@onready var title_label: Label = %TitleLabel
@onready var grid_container: GridContainer = %GridContainer
@onready var item_texture: TextureRect = %ItemTexture
@onready var craft_button: Button = %CraftButton
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var warning_label: Label = $WarningLabel

var color_active_text: Color = Color("5e412f")
var color_active_icon: Color = Color.WHITE
var color_locked_text: Color = Color(0.584, 0.514, 0.345, 1.0)
var color_locked_icon: Color = Color(0.0, 0.0, 0.0, 0.5)

var recipe_material_dict: Dictionary[Item, int] = {}
var inventory: InventoryComponent = null
var current_recipe: Recipe = null
var unique_id: int = ResourceUID.create_id()
var opened: Array[bool] = [true, true, true, true, true]

var all_recipe_items: Array[TreeItem] = []

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	GameManager.ui_opened_conditions[name + str(unique_id)] = func() -> bool: return visible
	
	craft_button.pressed.connect(_on_CraftButton_pressed)
	visibility_changed.connect(_on_visibility_changed)
	tree.item_selected.connect(_on_tree_cell_selected)
	
	tree.item_collapsed.connect(func(item: TreeItem) -> void:
		if !item: return
		if !item.has_meta(&"index"): return
		opened[item.get_meta(&"index")] = !item.collapsed
	)
	
	if warning_label:
		warning_label.visible = false

func _exit_tree() -> void:
	if is_instance_valid(GameManager):
		GameManager.ui_opened_conditions.erase(name + str(unique_id))

func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event.is_echo():
		return
	
	if event.is_action_pressed("down"):
		_navigate_list(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("up"):
		_navigate_list(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and (event.keycode == KEY_ENTER or event.keycode == KEY_SPACE)):
		_on_CraftButton_pressed()
		get_viewport().set_input_as_handled()

func _navigate_list(direction: int) -> void:
	if all_recipe_items.is_empty():
		return
		
	if not tree.has_focus():
		tree.grab_focus()

	var selected_item = tree.get_selected()
	var current_index = -1
	
	if selected_item:
		current_index = all_recipe_items.find(selected_item)
	
	var new_index = current_index + direction
	
	if current_index == -1:
		if direction > 0: new_index = 0
		else: new_index = all_recipe_items.size() - 1
	
	if new_index >= 0 and new_index < all_recipe_items.size():
		var target_item = all_recipe_items[new_index]
		var parent = target_item.get_parent()
		if parent and parent.collapsed:
			parent.collapsed = false
			if parent.has_meta(&"index"):
				opened[parent.get_meta(&"index")] = true
		
		target_item.select(0)
		tree.scroll_to_item(target_item)

func _on_visibility_changed() -> void:
	if visible:
		if GameManager.player and inventory == null:
			inventory = GameManager.player.inventory_component
		
		if inventory == null:
			return
		
		build_recipe_tree()
		clean_material_window()
		
		title_label.text = "Select Recipe"
		title_label.add_theme_color_override("font_color", color_active_text)
		
		item_texture.texture = null
		current_recipe = null
		
		if warning_label:
			warning_label.visible = false
			
		tree.grab_focus()
		
		if not all_recipe_items.is_empty():
			all_recipe_items[0].select(0)

func build_recipe_tree() -> void:
	tree.clear()
	all_recipe_items.clear()
	
	tree.hide_root = true
	var tree_root: TreeItem = tree.create_item()
	var categories: Dictionary = {}
	
	var custom_order = ["Weapons", "Tools", "Buildings", "Misc"]
	var index: int = 0
	
	for cat_name in custom_order:
		var cat_item = tree.create_item(tree_root)
		cat_item.set_text(0, cat_name)
		cat_item.set_selectable(0, false)
		cat_item.set_custom_color(0, color_active_text)
		
		cat_item.collapsed = !opened[index]
		cat_item.set_meta(&"index", index)
		categories[cat_name] = cat_item
		index += 1

	if DataManager.resources.has("recipes"):
		for recipe: Recipe in DataManager.resources["recipes"]:
			if recipe.category == "campfire": continue
			if !recipe.visible: continue
			
			var raw_cat = recipe.category
			if raw_cat == "" or raw_cat == null: raw_cat = "misc"
			var cat_name = raw_cat.capitalize()

			if not categories.has(cat_name):
				var cat_item = tree.create_item(tree_root)
				cat_item.set_text(0, cat_name)
				cat_item.set_selectable(0, false)
				cat_item.set_custom_color(0, color_active_text)
				
				var is_collapsed = true
				if index < opened.size():
					is_collapsed = !opened[index]
				cat_item.collapsed = is_collapsed
				cat_item.set_meta(&"index", index)
				categories[cat_name] = cat_item
				index += 1
			
			var parent_item = categories[cat_name]
			var item_slot: TreeItem = tree.create_item(parent_item)
			
			all_recipe_items.append(item_slot)
			
			if recipe.rewards.size() > 0:
				item_slot.set_text(0, recipe.rewards[0].display_name)
				item_slot.set_metadata(0, recipe)
				item_slot.set_icon(0, recipe.rewards[0].icon)
			
			if can_craft(recipe):
				item_slot.set_custom_color(0, color_active_text)
				item_slot.set_icon_modulate(0, color_active_icon)
			else:
				item_slot.set_custom_color(0, color_locked_text)
				item_slot.set_icon_modulate(0, color_locked_icon)

func _on_tree_cell_selected() -> void:
	var selected_item: TreeItem = tree.get_selected()
	if not selected_item: return

	var recipe = selected_item.get_metadata(0)
	if recipe:
		build_recipe_material_window(recipe)
	else:
		selected_item.collapsed = not selected_item.collapsed

func build_recipe_material_window(selected_recipe: Recipe) -> void:
	current_recipe = selected_recipe
	clean_material_window()
	
	if selected_recipe.rewards.size() > 0:
		title_label.text = selected_recipe.rewards[0].display_name
		item_texture.texture = selected_recipe.rewards[0].icon

	recipe_material_dict.clear()
	for recipe_material: Item in selected_recipe.costs:
		if recipe_material_dict.has(recipe_material):
			recipe_material_dict[recipe_material] += 1
		else:
			recipe_material_dict[recipe_material] = 1

	for recipe_material: Item in recipe_material_dict.keys():
		var required_amount: int = recipe_material_dict[recipe_material]
		var current_amount: int = inventory.count(recipe_material.id) if inventory else 0

		var slot: InventorySlotCrafting = INVENTORY_SLOT.instantiate()
		grid_container.add_child(slot)
		slot.set_item_data(recipe_material, current_amount, required_amount)

func clean_material_window() -> void:
	recipe_material_dict.clear()
	for child: Node in grid_container.get_children():
		child.queue_free()

func can_craft(recipe: Recipe) -> bool:
	if not inventory: return false

	var required_materials: Dictionary = {}
	for item_id: int in recipe.cost_ids:
		required_materials[item_id] = required_materials.get(item_id, 0) + 1

	for item_id: int in required_materials.keys():
		if inventory.count(item_id) < required_materials[item_id]:
			return false
	return true

func _on_CraftButton_pressed() -> void:
	if not current_recipe or not inventory: return

	var required_materials: Dictionary[int, int] = {}
	for item_id: int in current_recipe.cost_ids:
		required_materials[item_id] = required_materials.get(item_id, 0) + 1

	for item_id: int in required_materials.keys():
		if not inventory.has(item_id, required_materials[item_id]):
			_show_warning("Not enough resources!")
			return

	if current_recipe.reward_ids.size() > 0:
		var reward_id = current_recipe.reward_ids[0]
		if not inventory.can_add(reward_id, 1):
			_show_warning("Inventory is full! Free up space.")
			return

	for item_id: int in required_materials.keys():
		inventory.remove(item_id, required_materials[item_id])

	for reward_id: int in current_recipe.reward_ids:
		inventory.add(reward_id, 1)
	
	if [6,7,8,11,12,13,19,20,21].has(current_recipe.id):
		GameManager.finish_objective(4)
	audio_stream_player.play()

	build_recipe_material_window(current_recipe)
	build_recipe_tree()

func _show_warning(text: String) -> void:
	if warning_label:
		warning_label.text = text
		warning_label.visible = true
		craft_button.disabled = true
		
		await get_tree().create_timer(2.0).timeout
		
		if is_instance_valid(self):
			if is_instance_valid(craft_button):
				craft_button.disabled = false
			if is_instance_valid(warning_label):
				warning_label.visible = false

func _on_button_exit_pressed() -> void:
	close_requested.emit()
