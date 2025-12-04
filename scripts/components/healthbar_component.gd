@tool
class_name HealthBarComponent extends Component

const OVER: Texture2D = preload("uid://s4u2f0tmw74a")
const PROGRESS: Texture2D = preload("uid://bxjk04yub87ca")
const UNDER: Texture2D = preload("uid://bj4aukbhv42gu")
const OFFSET: Vector2 = Vector2(3.0, 2.0)

@export var gradient: Gradient = null

var healthbar: TextureProgressBar = null
var health_component: HealthComponent = null

func _ready() -> void:
	if Engine.is_editor_hint():
		queue_redraw()

func _draw() -> void:
	if Engine.is_editor_hint():
		draw_texture(OVER, Vector2.ZERO)

func _enter() -> void:
	# Health Component
	health_component = controller.get_component(HealthComponent)
	health_component.health_changed.connect(_on_health_changed)
	# Healthbar
	healthbar = TextureProgressBar.new()
	healthbar.texture_over = OVER
	healthbar.texture_under = UNDER
	healthbar.texture_progress = PROGRESS
	healthbar.texture_progress_offset = OFFSET
	healthbar.max_value = health_component.max_health
	healthbar.value = health_component.current_health
	add_child(healthbar)
	_on_health_changed(health_component.current_health)

func _update(_delta: float) -> void:
	pass

func _exit() -> void:
	pass

func _on_health_changed(new_health: float) -> void:
	healthbar.value = new_health
	healthbar.tint_progress = gradient.sample(healthbar.value)
