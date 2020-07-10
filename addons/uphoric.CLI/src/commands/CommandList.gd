extends Reference

enum CHECK {
	OK,
	FAILED,
	ALREADY_EXISTS
}

const COMMAND = preload("res://addons/uphoric.CLI/src/commands/Command.gd")
const LOAD_PATH: String = "res://addons/uphoric.CLI/load/"

var _commands: Dictionary = {}
var _loaded_commands: Dictionary = {}
var _command_names: Array = []


func add_command(name: String, function: FuncRef) -> int:
	var cmd = COMMAND.new(name, function)
	if(!has(name)):
		_commands[name] = cmd
		_command_names.append(name)
		return CHECK.OK
	else:
		return CHECK.ALREADY_EXISTS


func get_command(name: String):
	if(has(name)):
		return _commands[name]
	return null


func has(name: String) -> bool:
	return _commands.has(name)

func get_command_names() -> Array:
	return _command_names


func reload_commands() -> void:
	for key in _loaded_commands:
		if(key != "default.gd"):
			_loaded_commands.erase(key)
	
	_commands.clear()
	
	var dir := Directory.new()
	if dir.open(LOAD_PATH) == OK:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		
		while(!file_name.empty()):
			if(file_name.ends_with(".gd")):
				if(!_loaded_commands.has(file_name)):
					var command_script = load(LOAD_PATH + file_name)
					_loaded_commands[file_name] = command_script.new()
			
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	
	_regen_command_names()


func get_commands() -> Dictionary:
	return _commands


func _regen_command_names() -> void:
	_command_names.clear()
	for key in _commands:
		_command_names.append(key)
