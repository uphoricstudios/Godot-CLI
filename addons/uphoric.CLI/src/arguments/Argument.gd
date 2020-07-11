extends Reference

enum CHECK {
	OK,
	FAILED
}

var _types
var name: String
var description: String
var _type
var _original_value

func _init(name: String, type: int, description: String = "") -> void:
	self._types = load("res://addons/uphoric.CLI/src/types/Types.gd").new()
	self.name = name
	self._type = _types.get_type(type)
	self.description = description

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
	return "[" + name + ": " + _type._name + "] :: " + description


func get_original_value():
	return _original_value
