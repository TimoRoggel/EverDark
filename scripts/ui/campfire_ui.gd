extends Control

@onready var items: ItemList = %items
@onready var fuel_slot: InventorySlot = %fuel_slot
@onready var fuel_progress: ProgressBar = %fuel_progress
@onready var craft_button: Button = %craft_button

@onready var craftable_name: Label = %craftable_name
@onready var craftable_texture: TextureRect = %craftable_texture

@onready var requirements_name: Label = %requirements_name
@onready var requirement_texture: TextureRect = %requirement_texture
@onready var requirements_fuel_cost: Label = %requirements_fuel_cost

@onready var cook_audio: AudioStreamPlayer2D = %cook_audio
@onready var leave_area_check: Area2D = %leave_area_check

var selected: int = 0
var can_close: bool = true

func _ready() -> void:
	items.item_selected.connect(select)
	for r: Recipe in DataManager.resources["recipes"]:
		if r.rewards[0].fuel_cost <= 0:
			continue
		items.add_item(r.rewards[0].display_name, r.rewards[0].icon)
		items.set_item_metadata(items.item_count - 1, r)
	fuel_slot.filters = 1
	items.select(0)
	select(0)
	leave_area_check.body_exited.connect(func(body: Node) -> void:
		if body != GameManager.player:
			return
		if get_parent().visible:
			close()
	)

func _process(_delta: float) -> void:
	if get_parent().visible and can_close:
		if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("ui") or Input.is_action_just_pressed("interact"):
			close()

func _physics_process(_delta: float) -> void:
	if !is_visible_in_tree():
		return
	if !fuel_slot.inventory_item:
		return
	if fuel_progress.value >= fuel_progress.max_value:
		return
	var item: InventoryItem = fuel_slot.inventory_item
	if item.item.fuel_strength <= 0:
		return
	fuel_progress.value += item.item.fuel_strength
	fuel_slot.remove_amount(1)
	craft_button.disabled = !can_craft_recipe(items.get_item_metadata(selected))

func select(index: int) -> void:
	selected = index
	show_recipe(items.get_item_metadata(selected))

func show_recipe(recipe: Recipe) -> void:
	if recipe.cost_ids.size() <= 0:
		return
	craftable_name.text = recipe.rewards[0].display_name
	craftable_texture.texture = recipe.rewards[0].icon
	requirements_name.text = recipe.costs[0].display_name
	requirement_texture.texture = recipe.costs[0].icon
	requirements_fuel_cost.text = str(String.num(recipe.rewards[0].fuel_cost, 0), "% Fuel")
	craft_button.disabled = !can_craft_recipe(recipe)

func check_recipe_availability(recipe: Recipe = items.get_item_metadata(selected)) -> void:
	var inv: InventoryComponent = GameManager.player.inventory
	requirements_name.modulate = Color.RED if !inv.has(recipe.cost_ids[0]) else Color.WHITE
	requirements_fuel_cost.modulate = Color.RED if fuel_progress.value < recipe.rewards[0].fuel_cost else Color.WHITE

func can_craft_recipe(recipe: Recipe) -> bool:
	check_recipe_availability(recipe)
	return GameManager.player.inventory.has(recipe.cost_ids[0]) && fuel_progress.value >= recipe.rewards[0].fuel_cost

func _on_craft_button_pressed() -> void:
	var recipe: Recipe = items.get_item_metadata(selected)
	if !can_craft_recipe(recipe):
		return
	var inv: InventoryComponent = GameManager.player.inventory
	if !inv:
		return
	inv.remove(recipe.cost_ids[0])
	if inv.add(recipe.reward_ids[0]) > 0:
		DroppedItem2D.drop(recipe.reward_ids[0], 1, inv.global_position)
	fuel_progress.value -= recipe.rewards[0].fuel_cost
	show_recipe(recipe)
	cook_audio.play()

func _on_close_button_pressed() -> void:
	close()

func open() -> void:
	get_parent().visible = true
	check_recipe_availability()
	can_close = false
	
	get_tree().paused = true
	GameManager.paused = true
	GameManager.set_active_ui(self)
	await get_tree().create_timer(0.15, true, false, true).timeout
	can_close = true

func close() -> void:
	get_parent().visible = false
	
	get_tree().paused = false
	GameManager.paused = false
	GameManager.clear_active_ui()
