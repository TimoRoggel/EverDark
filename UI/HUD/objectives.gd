extends MarginContainer

@onready var objectives_label: RichTextLabel = %objectives_label
@onready var side_label: RichTextLabel = %side_label
@onready var objectives: Array[Label] = [%main_objective, %side_make_lumin, %side_gather, %side_kill, %side_upgrade, %side_expand, %side_cook]

func _ready() -> void:
	SaveSystem.track("objectives_done", func() -> int: return GameManager.objectives_done, func(val: int) -> void: GameManager.objectives_done = val, 0)

func _physics_process(_delta: float) -> void:
	var sides_done: bool = true
	var main_done: bool = false
	for i: int in 7:
		var byte: int = roundi(pow(2.0, float(i)))
		objectives[i].visible = !(GameManager.objectives_done & byte == byte)
		if i == 0:
			main_done = !objectives[i].visible
		elif objectives[i].visible:
			sides_done = false
	side_label.visible = !sides_done
	objectives_label.visible = !main_done || !sides_done
