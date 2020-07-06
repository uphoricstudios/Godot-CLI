extends Reference

enum AUTOTYPE {
	COMMAND,
	PATH
}

const PARSER = preload("res://addons/uphoric.CLI/src/console/InputParser.gd")
const _autos: Dictionary = {}


func get_auto(input: String, current: String) -> String:
	var input_arr: Array = PARSER.parse(input)
	if(input_arr[0] == current):
		return _find_command(current)
	return _find_path(current)


func set_auto(type: int, auto_data) -> void:
	if(_autos.has(str(type))):
		print("AutoComplete already has that data.")
		return
	_autos[str(type)] = auto_data
	print(_autos[str(type)])


func _find_command(text: String) -> String:
	var cmd_list: Array = _autos[str(AUTOTYPE.COMMAND)]
	for cmd in cmd_list:
		if(cmd.begins_with(text)):
			return cmd
	return ""


func _find_path(text: String) -> String:
	return "path"
