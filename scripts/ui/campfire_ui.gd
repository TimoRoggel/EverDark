extends Control

const LIT_SPRITE: Texture2D = preload("uid://br20pb2w1oq8m")
const UNLIT_SPRITE: Texture2D = preload("uid://dkenn8pic6tnm")

@onready var interactable: Interactable2D = get_parent().get_parent()
@onready var light: PointLight2D = %light
@onready var sprite: Sprite2D = %sprite

@onready var items: ItemList = %items
@onready var fuel_slot: InventorySlot = %fuel_slot
@onready var fuel_progress: TextureProgressBar = %fuel_progress
@onready var craft_button: Button = %craft_button

@onready var craftable_name: Label = %craftable_name
@onready var craftable_texture: TextureRect = %craftable_texture

@onready var requirements_name: Label = %requirements_name
@onready var requirement_texture: TextureRect = %requirement_texture
@onready var requirements_fuel_cost: Label = %requirements_fuel_cost

@onready var cook_audio: AudioStreamPlayer2D = %cook_audio
@onready var leave_area_check: Area2D = %leave_area_check

var selected: int = 0
var unique_id: int = ResourceUID.create_id()

func _ready() -> void:
	GameManager.ui_opened_conditions[name + str(unique_id)] = is_visible_in_tree
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
		_on_close_button_pressed()
	)
	update_sprite()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") && is_visible_in_tree():
		interactable.set_active(0.25)
		_on_close_button_pressed()

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
	update_sprite()

func _exit_tree() -> void:
	GameManager.ui_opened_conditions.erase(name + str(unique_id))

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
	if !inv:
		return
	requirements_name.modulate = Color.RED if !inv.has(recipe.cost_ids[0]) else Color.WHITE
	requirements_fuel_cost.modulate = Color.RED if fuel_progress.value < recipe.rewards[0].fuel_cost else Color.WHITE

func can_craft_recipe(recipe: Recipe) -> bool:
	check_recipe_availability(recipe)
	if !GameManager.player:
		return false
	if !GameManager.player.inventory:
		return false
	return GameManager.player.inventory.has(recipe.cost_ids[0]) && fuel_progress.value >= recipe.rewards[0].fuel_cost

func update_sprite() -> void:
	var has_fuel: bool = fuel_progress.value > 0
	sprite.texture = LIT_SPRITE if has_fuel else UNLIT_SPRITE
	light.visible = has_fuel

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
	get_parent().visible = false
	get_tree().paused = false
	GameManager.player.hotbar.visible = true
	GameManager.player.inventory.container.visible = false
