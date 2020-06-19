extends "BaseType.gd"

const regex_pattern = "^[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)$"


func _init() -> void:
	_name = 'Float'
	_type = TYPE_REAL


func normalize(original_value: String):
	var regex := RegEx.new()
	regex.compile(regex_pattern)
	var result: RegExMatch = regex.search(original_value)
	if(result):
		var float_string:String = result.get_string()
		if(float_string.begins_with(".")):
			float_string = "0" + float_string
		elif(float_string.ends_with(".")):
			float_string += "0"
		_normalized_value = float(result.get_string())
		return CHECK.OK
	else:
		return CHECK.FAILED
