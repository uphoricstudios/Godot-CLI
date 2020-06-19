extends "BaseType.gd"


func _init() -> void:
	_name = 'String'
	_type = TYPE_STRING


func normalize(original_value: String):
	_normalized_value = str(original_value)
	return CHECK.OK
