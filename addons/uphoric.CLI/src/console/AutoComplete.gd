extends Reference

enum AUTOTYPE {
	COMMAND,
	PATH
}

const PARSER = preload("res://addons/uphoric.CLI/src/console/InputParser.gd")
const _autos: Dictionary = {}


func get_auto(input: String) -> String:
	return _find_command(input)


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
