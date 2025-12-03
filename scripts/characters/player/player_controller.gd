class_name PlayerController extends CharacterController

@export var held_item_sprite: Sprite2D = null

var input: InputComponent = null
var movement: MoveComponent = null
var weapon: SpawnAttackComponent = null
var block: BlockComponent = null
var animation: AnimationComponent = null
var dash: DashComponent = null
var camera: CameraComponent = null
var inventory: InventoryComponent = null
var health: HealthComponent = null
var hitbox: HitboxComponent = null
var hurtbox: HitboxComponent = null
var build: BuildComponent = null
var everdark_damage: EverdarkDamageComponent = null
var death: DeathComponent = null
var eat: EatComponent = null

@onready var hud: Control = $CanvasLayer/HUD

@onready var hotbar: HBoxContainer = $CanvasLayer/hotbar
@onready var death_view: Control = $pause/DeathView

func _init() -> void:
	flags = CharacterFlags.Player

func _ready() -> void:
	show()
	SaveSystem.track("position", get_position, set_position, Vector2.ZERO)
	super()
	GameManager.player = self
	await get_tree().process_frame
	input = get_component(InputComponent)
	animation = get_component(AnimationComponent)
	movement = get_component(MoveComponent)
	weapon = get_component(SpawnAttackComponent)
	block = get_component(BlockComponent)
	dash = get_component(DashComponent)
	camera = get_component(CameraComponent)
	inventory = get_component(InventoryComponent)
	health = get_component(HealthComponent)
	hitbox = get_component(HitboxComponent)
	build = get_component(BuildComponent)
	everdark_damage = get_component(EverdarkDamageComponent)
	if everdark_damage and hud:
		everdark_damage.virusbar_setup.connect(hud._on_setup_virusbar)
		everdark_damage.virus_effect.connect(hud._on_virus_effect)
		everdark_damage.everdark_entered.connect(hud.toggle_virus_view)
		everdark_damage.create_virus_timer()
	death = get_component(DeathComponent)
	if death_view and death:
		death_view.respawn_pressed.connect(death.respawn)
	eat = get_component(EatComponent)

func _custom_physics_process(delta: float) -> void:
	super(delta)
	if !movement:
		return
	movement.desired_movement = input.movement
	if block:
		block.block_angle = input.angle_to_cursor
	if weapon:
		weapon.attack_id = -1
		if inventory:
			var held_item_id: int = inventory.get_held_item_id()
			if held_item_id == -1:
				weapon.attack_id = 0
				held_item_sprite.texture = null
			else:
				var held_item: Item = DataManager.get_resource_by_id("items", held_item_id)
				held_item_sprite.texture = held_item.icon
				weapon.attack_id = held_item.weapon_id
			held_item_sprite.visible = !animation.animated_sprite.animation.begins_with(AnimationComponent.ANIMS[2])
			animation.held_item = held_item_id
		weapon.attack_angle = input.angle_to_cursor
		weapon.attacking = input.attacking
	if dash:
		dash.dashing = input.dashing
		dash.default_dash = Vector2.from_angle(input.angle_to_cursor)
	if animation:
		var should_flip: bool = input.angle_to_cursor > WeaponComponent.HPI || input.angle_to_cursor < -WeaponComponent.HPI
		animation.should_flip = (should_flip || input.movement.x < 0.0) && input.movement.x <= 0.0
		held_item_sprite.flip_h = animation.should_flip
		held_item_sprite.position.x = 8.0 * (-1.0 if animation.should_flip else 1.0)
		held_item_sprite.position.y = -2.0 if animation.is_looking_up() else (2.0 if animation.is_looking_down() else 0.0)
		var target_direction: Vector2 = animation.direction
		if input.movement.length() > 0.5:
			target_direction = input.movement
		elif input.attacking:
			target_direction = Vector2.from_angle(input.angle_to_cursor)
		animation.direction = target_direction
		animation.attacking = weapon.attack_active

func on_bounce(bounce_amount: float) -> void:
	camera.shake(bounce_amount * 0.02, 0.1)
	
