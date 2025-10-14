class_name Item extends DataDrivenResource

@export var display_name: String = ""
@export var icon: Texture2D = null
@export var stack_size: int = 64
@export var flags: int = 0

static func from_data(data: Dictionary) -> Item:
	var item: Item = Item.new()
	item.id = data["id"]
	item.display_name = data["name"]
	item.icon = load(data["icon"])
	item.stack_size = data["stack_size"]
	return item
