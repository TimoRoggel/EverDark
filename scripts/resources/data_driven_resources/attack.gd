class_name Attack extends DataDrivenResource

@export_group("Info")
@export var texture: Texture2D = null
@export var weapon_sprite: Texture2D = null
@export_enum("Primary", "Secondary") var weapon_type: int = 0
@export var power: float = 1.0
@export var invulnerability: float = 0.05
@export_group("Velocity")
@export var inheritance: float = 0.5
@export var speed: float = 16.0
@export var velocity_overtime: Curve = null
@export var knockback: float = 0.5
@export_range(0, 1, 0.001) var speed_randomness: float = 0.0
@export var align_rotation: bool = false
@export_group("Spawn")
@export var kickback: float = 0.0
@export var firerate: float = 0.1
@export var lifetime: float = 5.0
@export_range(0, 1, 0.001) var lifetime_randomness: float = 0.0
@export var spread: float = 0.1
@export var count: int = 1
@export var spawn_distance: float = 0.0
@export var attached_to_owner: bool = false
@export_group("Hurtbox")
@export var hurtbox: Rect2i = Rect2i()
@export var can_hit_owner: bool = false
@export_group("Flair")
@export var attack_sound: AudioStream = null
@export_subgroup("Particles", "particle_")
@export var particle_material: ParticleProcessMaterial = null
@export var particle_texture: Texture2D = null
@export var particle_amount: int = 10
@export_range(0, 1, 0.001) var particle_amount_ratio: float = 1.0
@export var particle_lifetime: float = 0.25
@export var particle_oneshot: bool = false
@export_range(0, 600, 0.1) var particle_preprocess: float = 0.0
@export_range(0, 64, 0.1) var particle_speed_scale: float = 1.0
@export_range(0, 1, 0.001) var particle_explosiveness: float = 0.0
@export_range(0, 1, 0.001) var particle_randomness: float = 0.0
@export_subgroup("Screen Shake", "shake_")
@export_range(0, 64, 0.1) var shake_amount: float = 1.0
@export_range(0, 1, 0.001) var shake_duration: float = 0.1
@export var shake_addative: bool = false
@export_range(0, 1, 0.001) var slowdown: float = 0.75
@export_range(0, 10000) var slowdown_duration_ms: int = 100
@export var color_over_time: GradientTexture1D = null
@export var alpha_over_time: CurveTexture = null
@export var death_attack: Attack = null
@export var harvest_level: int = 0
@export var flags: int = 0
@export var cost: int = -1

static func from_data(data: Dictionary) -> Attack:
	var attack: Attack = Attack.new()
	attack.id = data["id"]
	attack.texture = DataDrivenResource.get_loaded(data, "texture")
	attack.weapon_sprite = DataDrivenResource.get_loaded(data, "weapon_sprite")
	attack.attack_sound = DataDrivenResource.get_loaded(data, "attack_sound")
	attack.power = data["power"]
	attack.invulnerability = int(data["invulnerability"]) * 0.001
	attack.inheritance = data["inheritance"]
	attack.speed = data["speed"]
	attack.velocity_overtime = DataDrivenResource.get_loaded(data, "velocity_overtime")
	attack.knockback = data["knockback"]
	attack.speed_randomness = data["speed_randomness"]
	attack.align_rotation = data["align_rotation"] == "TRUE"
	attack.kickback = data["kickback"]
	attack.firerate = data["firerate"]
	attack.lifetime = data["lifetime"]
	attack.lifetime_randomness = data["lifetime_randomness"]
	attack.spread = data["spread"]
	attack.spawn_distance = data["spawn_distance"]
	attack.attached_to_owner = data["attached_to_owner"] == "TRUE"
	attack.hurtbox = Rect2i(0, 0, data["hurtbox_width"], data["hurtbox_height"])
	attack.can_hit_owner = data["can_hit_owner"] == "TRUE"
	attack.alpha_over_time = DataDrivenResource.get_loaded(data, "alpha_over_time")
	attack.harvest_level = data["harvest_level"]
	attack.flags = data["flags"]
	attack.cost = data["cost"]
	return attack

func rand_range(base: float, randomness: float) -> float:
	var rand: float = base * randomness
	return randf_range(-rand, rand) + base

func get_lifetime() -> float:
	return rand_range(lifetime, lifetime_randomness)

func get_speed() -> float:
	return rand_range(speed, speed_randomness)
