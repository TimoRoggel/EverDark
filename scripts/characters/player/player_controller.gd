class_name PlayerController extends CharacterController

var input: InputComponent = null
var movement: MoveComponent = null
var weapon: WeaponComponent = null
var secondary: SpawnProjectileComponent = null
var animation: AnimationComponent = null
var dash: DashComponent = null
var camera: CameraComponent = null
var inventory: InventoryComponent = null

func _init() -> void:
	flags = CharacterFlags.Player

func _ready() -> void:
	super()
	await get_tree().process_frame
	input = get_component(InputComponent)
	movement = get_component(MoveComponent)
	weapon = get_component(WeaponComponent)
	secondary = get_component(SpawnProjectileComponent, 1)
	animation = get_component(AnimationComponent)
	dash = get_component(DashComponent)
	camera = get_component(CameraComponent)
	inventory = get_component(InventoryComponent)
	await Generator.generate(Vector2.ZERO)

func _custom_physics_process(delta: float) -> void:
	super(delta)
	if !movement:
		return
	movement.desired_movement = input.movement
	if weapon:
		weapon.desired_rotation = input.angle_to_cursor
	if secondary:
		secondary.shoot_angle = weapon.shoot_angle
	if animation:
		var should_flip: bool = input.angle_to_cursor > WeaponComponent.HPI || input.angle_to_cursor < -WeaponComponent.HPI
		animation.should_flip = should_flip || input.movement.x < 0
	if weapon:
		weapon.shooting = input.shooting
		secondary.shooting = input.secondary_shooting
		if input.shooting || input.secondary_shooting:
			weapon.weapon_sprite.texture = weapon.bullet_type.weapon_sprite if input.shooting else secondary.bullet_type.weapon_sprite
	if dash:
		dash.dashing = input.dashing
		dash.default_dash = Vector2.from_angle(input.angle_to_cursor)

func on_bounce(bounce_amount: float) -> void:
	camera.shake(bounce_amount * 0.02, 0.1)
