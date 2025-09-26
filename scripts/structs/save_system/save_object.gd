@abstract
class_name SaveObject extends RefCounted

var name: String = ""

@abstract func save_data() -> Dictionary

@abstract func load_data(data: Dictionary) -> void

@abstract func clean_data() -> void
