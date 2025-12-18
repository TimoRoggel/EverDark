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
@onready var fuel_amount: Label = %fuel_amount

@onready var craftable_name: Label = %craftable_name
@onready var craftable_texture: TextureRect = %craftable_texture

@onready var requirement_texture: TextureRect = %requirement_texture
@onready var requirements_fuel_cost: Label = %requirements_fuel_cost
@onready var requirements_amount: Label = %requirements_amount

@onready var cook_audio: AudioStreamPlayer2D = %cook_audio
@onready var leave_area_check: Area2D = %leave_area_check

var selected: int = 0
var can_close: bool = true
var unique_id: int = ResourceUID.create_id()

func _ready() -> void:
	GameManager.ui_opened_conditions[name + str(unique_id)] = is_visible_in_tree
	items.item_selected.connect(select)
	for r: Recipe in DataManager.resources["recipes"]:
		if r.rewards[0].fuel_cost <= 0:
			continue
		items.add_item(r.rewards[0].display_name, r.rewards[0].icon)
		items.set_item_metadata(items.item_count - 1, r)
		items.set_item_tooltip(items.item_count - 1, r.rewards[0].display_name + "\n" + r.rewards[0].description)
	fuel_slot.filters = 1
	items.select(0)
	select(0)
	leave_area_check.body_exited.connect(func(body: Node) -> void:
		if body != GameManager.player:
			return
		if get_parent().visible:
			close()
	)
	update_sprite()
	fuel_amount.text = str(String.num(fuel_progress.value, 0), "%")
	interactable.input_event.connect(_on_input_event)

func _on_input_event(_viewport: Node, event: InputEvent, _idx: int) -> void:
	if event.is_action_pressed("pickup"):
		interactable.active = false
		var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
		tween.tween_property(interactable, "scale", Vector2.ONE * 0.1, 0.2)
		tween.play()
		await tween.finished
		var remainder: int = GameManager.player.inventory.add(26)
		if remainder > 0:
			DroppedItem2D.drop(26, 1, interactable.global_position)
		_on_close_button_pressed()
		WorldStateSaver.placed_items.erase(interactable.name)
		interactable.queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") && is_visible_in_tree():
		interactable.set_active(0.25)
		_on_close_button_pressed()

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
	fuel_amount.text = str(String.num(fuel_progress.value, 0), "%")
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
	requirements_amount.text = str(recipe.get_cost_count(recipe.cost_ids[0]), "x")
	requirement_texture.texture = recipe.costs[0].icon
	requirements_fuel_cost.text = str(String.num(recipe.rewards[0].fuel_cost, 0), "% fuel needed")
	craft_button.disabled = !can_craft_recipe(recipe)

func check_recipe_availability(recipe: Recipe = items.get_item_metadata(selected)) -> void:
	var inv: InventoryComponent = GameManager.player.inventory
	if !inv:
		return
	requirements_amount.modulate = Color.RED if !inv.has(recipe.cost_ids[0], recipe.get_cost_count(recipe.cost_ids[0])) else Color.WHITE
	requirements_fuel_cost.modulate = Color.RED if fuel_progress.value < recipe.rewards[0].fuel_cost else Color.WHITE

func can_craft_recipe(recipe: Recipe) -> bool:
	check_recipe_availability(recipe)
	if !GameManager.player:
		return false
	if !GameManager.player.inventory:
		return false
	return GameManager.player.inventory.has(recipe.cost_ids[0], recipe.get_cost_count(recipe.cost_ids[0])) && fuel_progress.value >= recipe.rewards[0].fuel_cost

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
	fuel_amount.text = str(String.num(fuel_progress.value, 0), "%")
	show_recipe(recipe)
	cook_audio.play()
	GameManager.finish_objective(6)

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
	GameManager.player.hotbar.visible = true
	GameManager.player.inventory.container.visible = false
	if fuel_slot.inventory_item:
		DroppedItem2D.drop(fuel_slot.inventory_item.item.id, fuel_slot.inventory_item.quantity, GameManager.player.global_position, false)
		fuel_slot.inventory_item = null
		fuel_slot._setup_item()
