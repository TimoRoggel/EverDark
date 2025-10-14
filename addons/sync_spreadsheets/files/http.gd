@tool
extends Node
class_name HTTP

const HEADER: PackedStringArray = ["Content-Type: application/json; charset=UTF-8"]

func req(url: String, ## url ended in /
		callback: Callable, ## callback(response: Variant)
		method: HTTPClient.Method = HTTPClient.METHOD_GET,
		query: Dictionary = {},
		body: Dictionary = {},
		headers: PackedStringArray = HEADER,
		path: String = "") -> void:
	
	var http_request: HTTPRequest = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(func(r: int, c: int, h: PackedStringArray, b: PackedByteArray): _req_completed(r, c, h, b, callback))
	
	var QUERY: String = "?" + "&".join(query.keys().map(func(k): return k.uri_encode() + "=" + str(query[k]).uri_encode()))
	var error: Error = 0
	var body_str: String = JSON.new().stringify(body) if body else ""
	
	if path != "":
		http_request.set_download_file(path)
	error = http_request.request(url + QUERY, headers, method, body_str)
	if error != OK:
		push_error("An error occurred in the HTTP request. This should be not happened, is a code error!")

func _req_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, callback: Callable) -> void:
	var err: Error = OK
	if result != HTTPRequest.RESULT_SUCCESS:
		printerr("ERROR: You are OFFLINE")
		err = result
	elif response_code >= 400:
		printerr("ERROR: Request INVALID")
		err = response_code

	var json: JSON = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response: Variant = json.get_data()
	callback.call(response)
	
	if err != OK:
		printerr("ERROR response: ", response)
