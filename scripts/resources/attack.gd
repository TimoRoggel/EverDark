class_name Attack extends Resource

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

func rand_range(base: float, randomness: float) -> float:
	var rand: float = base * randomness
	return randf_range(-rand, rand) + base

func get_lifetime() -> float:
	return rand_range(lifetime, lifetime_randomness)

func get_speed() -> float:
	return rand_range(speed, speed_randomness)
