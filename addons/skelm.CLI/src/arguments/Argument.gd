extends Reference

enum CHECK {
	OK,
	FAILED
}

var _types
var _name: String
var _description: String
var _type
var _original_value

func _init(name: String, type: int, description: String = "") -> void:
	_types = load("res://addons/skelm.CLI/src/types/Types.gd").new()
	_name = name
	_type = _types.get_type(type)
	_description = description

func set_value(value: String) -> int:
	_original_value = value
	var check: int = _type.normalize(value)
	if(check == CHECK.FAILED):
		return CHECK.FAILED
	else:
		return CHECK.OK


func get_value():
	return _type.get_normalized_value()


func describe() -> String:
	return "[" + _name + ": " + _type._name + "] :: " + _description


func get_original_value():
	return _original_value
