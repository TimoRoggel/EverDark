class_name LoreNoteRunnable extends Runnable

func run(param: Dictionary) -> void:
	if !param.has("note"):
		return
	LoreSystem.unlock_note(param["note"])
	LoreSystem.open_screen(DataManager.get_resource_by_id("notes", param["note"]))
	param["self"].queue_free()

func can_run(param: Dictionary) -> bool:
	return param.has("note")
