extends Node

@export var data: Dictionary[String, Array] = {}
@export var resources: Dictionary[String, Array] = {
	"biomes": [preload("uid://dsi2onu11ycrk"), preload("uid://dekmbcv21co4f"), preload("uid://bxnerdbrm1woq"), preload("uid://ck3g1gb232ijv")]
}

func _ready() -> void:
	load_data("items")
	resources["items"] = []
	for item: Dictionary in data["items"]:
		resources["items"].append(Item.from_data(item))
	#load_data("biomes")
	#resources["biomes"] = []
	#for item: Dictionary in data["biomes"]:
		#resources["biomes"].append(Biome.from_data(item))

func load_data(key: String) -> void:
	data[key] = []
	var file: FileAccess = FileAccess.open("res://data/" + key + ".csv", FileAccess.READ)
	var lines: PackedStringArray = file.get_as_text().replace("\r", "").split("\n")
	var keys: PackedStringArray = []
	for i: int in lines.size():
		var line: String = lines[i]
		if i == 0:
			keys = line.split(",")
			for j: int in keys.size():
				keys[j] = keys[j].replace("\"", "")
			continue
		var info: Dictionary[String, Variant] = {}
		var values: PackedStringArray = line.split(",")
		var new_values: PackedStringArray = values
		#var k: int = 0
		#while new_values.size() < keys.size():
			#var v: String = values[k]
			#if v.contains("[") && !v.contains("]"):
				#v += ","
				#while !v.contains("]"):
					#k += 1
					#v += values[k] + ("" if values[k].contains("]") else ",")
			#k += 1
			#new_values.append(v)
		for j: int in keys.size():
			var value: Variant = str_to_var(new_values[j])
			if value is String:
				if value.is_valid_int():
					value = value.to_int()
				elif value.is_valid_float():
					value = value.to_float()
				#elif JSON.parse_string(value):
					#value = JSON.parse_string(value)
			info[keys[j]] = value
		data[key].append(info)
