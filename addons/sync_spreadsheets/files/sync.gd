@tool
extends Control

const SYNC_LOCATION: String = ""#"res://addons/sync_spreadsheets/_sync_csv_spreadsheets.res"
const CONFIG_LOCATION: String = ""#"res://addons/sync_spreadsheets/_sync_csv_spreadsheets.cfg"

@onready var http : HTTP = $HTTP

var sheets_resource : Resource

# TODO: configure this options
var options = {
	auto_sync_on_open_tab = true,
	auto_sync_on_play = false,
	auto_scan_for_csv_files = true,
}

var config = ConfigFile.new()


func _ready():
	sheets_resource = SheetsResource.new([
		SheetResource.new("res://data/items.csv", "1625O4iMQZqi9_kXD7bO6tz-KfY_-GNBzAe-nHMraaSU", "Items"),
		SheetResource.new("res://data/recipes.csv", "1625O4iMQZqi9_kXD7bO6tz-KfY_-GNBzAe-nHMraaSU", "Recipes")
	])
	_load_config()
	_sync_csv_files()
	_save_config()


func _sync_csv_files():
	var csv_paths = _get_all_file_paths("res://", ".csv")
	print(sheets_resource.sheets)
	for csv_path in csv_paths:
		var exist = sheets_resource.sheets.filter(func(s): return s.csv_path == csv_path)
		if not exist:
			var new_sheet_resource : Resource = SheetResource.new(csv_path, "", "", "", Time.get_datetime_string_from_system(), true)
			sheets_resource.sheets.append(new_sheet_resource)
	
	for sheet in sheets_resource.sheets:
		if csv_paths.has(sheet.csv_path):
			_sync_sheet(sheet)


func _load_config():
	var err = config.load(CONFIG_LOCATION)
	if err == OK:
		config.get_value("Options", "options", options)
	
	if ResourceLoader.exists(SYNC_LOCATION):
		var new_sheets_resource = ResourceLoader.load(SYNC_LOCATION)
		print(", ".join(new_sheets_resource.sheets.map(func(sheet): return sheet.sheet_name)))
		if new_sheets_resource is SheetsResource:
			sheets_resource = new_sheets_resource
	
	_save_config()


func _save_config():
	if !ResourceLoader.exists(SYNC_LOCATION):
		return
	ResourceSaver.save(sheets_resource, SYNC_LOCATION)
	config.set_value("Options", "options", options)
	config.save(CONFIG_LOCATION)
	#print("Sync CSV Spreadsheets configurations saved!")


func _sync_sheet(sheet : SheetResource):
	if sheet.sheet_id and sheet.csv_path:
		var url = "https://docs.google.com/spreadsheets/d/" + sheet.sheet_id + "/gviz/tq"
		if sheet.sheet_name:
			http.req(url, func(r, err): _sync_sheet_callback(r, err, sheet), HTTPClient.METHOD_GET, { "tqx": "out:csv", "sheet": sheet.sheet_name }, {}, [], sheet.csv_path)
		elif sheet.sheet_gid:
			http.req(url, func(r, err): _sync_sheet_callback(r, err, sheet), HTTPClient.METHOD_GET, { "tqx": "out:csv", "gid": sheet.sheet_gid }, {}, [], sheet.csv_path)
		else:
			return
		sheet.updated_at = Time.get_datetime_string_from_system()
		return sheet


func _sync_sheet_callback(r, err, sheet):
	sheet.updated_at = Time.get_datetime_string_from_system()
	_save_config()


func _sync(url, sheet_name, csv_path):
	http.req(url, func(r, err): printt(r, err), HTTPClient.METHOD_GET, { "tqx": "out:csv", "sheet": sheet_name }, {}, [], csv_path)


func _get_all_file_paths(path: String, file_extension: String = "") -> Array[String]:
	var file_paths: Array[String] = []
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var file_path = path + "/" + file_name
		if dir.current_is_dir():
			file_paths += _get_all_file_paths(file_path, file_extension)
		else:
			if file_path.ends_with(file_extension):
				file_paths.append(file_path)
		file_name = dir.get_next()
	dir.list_dir_end()
	return file_paths


func _on_open_sheets_resource_pressed():
	#printt("Showing", sheets_resource)
	EditorInterface.get_inspector().resource_selected.emit(sheets_resource, SYNC_LOCATION)
	

func _on_save_sheets_resource_pressed():
	_save_config()
	#printt("Saved: ", sheets_resource.sheets[0].sheet_id)
	_load_config()
	#printt("Loaded: ", sheets_resource.sheets[0].sheet_id)


func _on_sync_now_pressed():
	_sync_csv_files()
