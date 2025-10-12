class_name PlayerController extends CharacterController

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
var everdark_damage: EverdarkDamageComponent = null

@onready var hud: Control = $CanvasLayer/HUD

func _init() -> void:
	flags = CharacterFlags.Player

func _ready() -> void:
	SaveSystem.track("position", get_position, set_position, Vector2.ZERO)
	super()
	await get_tree().process_frame
	input = get_component(InputComponent)
	movement = get_component(MoveComponent)
	weapon = get_component(SpawnAttackComponent)
	block = get_component(BlockComponent)
	animation = get_component(AnimationComponent)
	dash = get_component(DashComponent)
	camera = get_component(CameraComponent)
	inventory = get_component(InventoryComponent)
	health = get_component(HealthComponent)
	hitbox = get_component(HitboxComponent)
	everdark_damage = get_component(EverdarkDamageComponent)
	await Generator.generate(Vector2.ZERO)

func _custom_physics_process(delta: float) -> void:
	super(delta)
	if !movement:
		return
	movement.desired_movement = input.movement
	if block:
		block.block_angle = input.angle_to_cursor
	if animation:
		var should_flip: bool = input.angle_to_cursor > WeaponComponent.HPI || input.angle_to_cursor < -WeaponComponent.HPI
		animation.should_flip = should_flip || input.movement.x < 0
	if weapon:
		weapon.attack_angle = input.angle_to_cursor
		weapon.attacking = input.attacking
	if dash:
		dash.dashing = input.dashing
		dash.default_dash = Vector2.from_angle(input.angle_to_cursor)
	if animation:
		var should_flip: bool = input.angle_to_cursor > WeaponComponent.HPI || input.angle_to_cursor < -WeaponComponent.HPI
		animation.should_flip = should_flip || input.movement.x < 0

func on_bounce(bounce_amount: float) -> void:
	camera.shake(bounce_amount * 0.02, 0.1)
