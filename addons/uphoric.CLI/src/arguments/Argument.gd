extends Reference

enum CHECK {
	OK,
	FAILED
}

var _name: String
var _description: String

var _optional: bool
var _types
var _type
var _original_value

func _init(name: String, type: int, description: String = "", optional: bool = false) -> void:
	self._types = load("res://addons/uphoric.CLI/src/types/Types.gd").new()
	self._name = name
	self._description = description
	self._optional = optional
	self._type = _types.get_type(type)

func set_value(value: String) -> int:
	_original_value = value
	var check: int = _type.normalize(value)
	if(check == CHECK.FAILED):
		return CHECK.FAILED
	else:
		return CHECK.OK


func get_value():
	return _type.get_normalized_value()


func get_name() -> String:
	return _name


func get_description() -> String:
	return _description


func get_type() -> String:
	return _type._name


func get_original_value():
	return _original_value


func is_optional() -> bool:
	return _optional
