extends "BaseType.gd"

const regex_pattern = "^[+-]?\\d+$"


func _init() -> void:
	_name = 'Int'
	_type = TYPE_INT


func normalize(original_value: String):
	var regex := RegEx.new()
	regex.compile(regex_pattern)
	var result: RegExMatch = regex.search(original_value)
	if(result):
		_normalized_value = int(result.get_string())
		return CHECK.OK
	else:
		return CHECK.FAILED
