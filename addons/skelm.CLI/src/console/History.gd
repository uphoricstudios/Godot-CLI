extends Reference

var _size: int
var _current_index: int
var _commands: Array


func _init(size: int = 20) -> void:
	_size = size
	_current_index = 0
	_commands = []


func reset() -> void:
	_current_index = 0


func next() -> String:
	if(_commands.empty()):
		return ""
	var result: String = _commands[_current_index]
	var real_size: int = min(_size, len(_commands)) - 1
	_current_index = min(_current_index + 1, real_size)
	return result


func previous() -> String:
	if(_commands.empty() || _current_index == 0):
		return ""
	_current_index = max(_current_index - 1, 0)
	var result: String = _commands[_current_index]
	return result


func push(command: String) -> void:
	_commands.push_front(command)
	if(len(_commands) > 20):
		_commands.resize(_size)
