class_name SaveRemovalComponent extends Component

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		WorldStateSaver.destroyed_items.append(controller.name)

func _enter() -> void:
	pass

func _update(_delta: float) -> void:
	pass

func _exit() -> void:
	pass
