@tool
extends Control

@onready var http: HTTP = $HTTP

var sheets_resource: SheetsResource = null

func _ready() -> void:
	sheets_resource = SheetsResource.new([
		SheetResource.new("res://data/items.csv", "1625O4iMQZqi9_kXD7bO6tz-KfY_-GNBzAe-nHMraaSU", "Items"),
		SheetResource.new("res://data/recipes.csv", "1625O4iMQZqi9_kXD7bO6tz-KfY_-GNBzAe-nHMraaSU", "Recipes"),
		SheetResource.new("res://data/harvestables.csv", "1625O4iMQZqi9_kXD7bO6tz-KfY_-GNBzAe-nHMraaSU", "Harvestables"),
		SheetResource.new("res://data/notes.csv", "1625O4iMQZqi9_kXD7bO6tz-KfY_-GNBzAe-nHMraaSU", "Notes"),
	])
	_sync_csv_files()

func _sync_csv_files() -> void:
	for sheet: SheetResource in sheets_resource.sheets:
		_sync_sheet(sheet)

func _sync_sheet(sheet: SheetResource) -> void:
	if sheet.sheet_id && sheet.csv_path:
		var url: String = "https://docs.google.com/spreadsheets/d/" + sheet.sheet_id + "/gviz/tq"
		if sheet.sheet_name:
			http.req(url, func(r: Variant): _sync_sheet_callback(r, sheet), HTTPClient.METHOD_GET, { "tqx": "out:csv", "sheet": sheet.sheet_name }, {}, [], sheet.csv_path)
		elif sheet.sheet_gid:
			http.req(url, func(r: Variant): _sync_sheet_callback(r, sheet), HTTPClient.METHOD_GET, { "tqx": "out:csv", "gid": sheet.sheet_gid }, {}, [], sheet.csv_path)
		else:
			return
		sheet.updated_at = Time.get_datetime_string_from_system()
		return

func _sync_sheet_callback(r: Variant, sheet: SheetResource) -> void:
	sheet.updated_at = Time.get_datetime_string_from_system()

func _sync(url: String, sheet_name: String, csv_path: String) -> void:
	http.req(url, func(r: int, err: int): printt(r, err), HTTPClient.METHOD_GET, { "tqx": "out:csv", "sheet": sheet_name }, {}, [], csv_path)

func _on_sync_now_pressed() -> void:
	_sync_csv_files()
