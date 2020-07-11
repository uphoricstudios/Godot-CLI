extends Reference

const PARSER = preload("res://addons/uphoric.CLI/src/helpers/InputParser.gd")
const _autos: Dictionary = {}


func get_auto(input: String, current: String) -> String:
	var input_arr: Array = PARSER.parse(input)
	
	if(input_arr.empty()):
		return ""
	
	if(input_arr[0] == current):
		return _find_command(current)
	
	return _find_path(current)


func set_auto(type: String, auto_data) -> void:
	_autos[type] = auto_data


func _find_command(text: String) -> String:
	var cmd_list: Array = _autos["commands"]
	for cmd in cmd_list:
		if(cmd.begins_with(text)):
			return cmd
	return ""


func _find_path(path: String) -> String:
	var result: String = ""
	var dir := Directory.new()
	if dir.open(_autos["path"]) == OK:
		
		var last_slash: int = path.find_last("/")
		if(last_slash != -1):
			var part_path: String = path.substr(0, last_slash + 1)
			var complete_path: String = _autos["path"] + part_path
			var part_file_name: String = path.substr(last_slash + 1)
			var error: int = dir.change_dir(part_path)
			
			if(error != OK):
				return ""
			
			else:
				result = _find_file(complete_path, part_file_name)
				
				if(result.empty()):
					return ""
				
				else:
					return part_path + result
		
		else:
			return _find_file(_autos["path"], path)
	
	return ""


func _find_file(dir_path: String, file_name: String) -> String:
	var dir := Directory.new()
	
	if dir.open(dir_path) == OK:
		dir.list_dir_begin(true, true)
		var current: String = dir.get_next()
		
		while(!current.empty()):
			if(current.begins_with(file_name)):
				return current
			
			current = dir.get_next()
	
	return ""
