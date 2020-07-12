extends "BaseType.gd"

const regex_pattern = "^(true|false)$"


func _init() -> void:
	_name = 'Bool'
	_type = TYPE_INT


func normalize(original_value: String):
	var regex := RegEx.new()
	regex.compile(regex_pattern)
	var result: RegExMatch = regex.search(original_value.to_lower())
	if(result):
		if(result.get_string() == "true"):
			_normalized_value = true
		else:
			_normalized_value = false
		return CHECK.OK
	else:
		return CHECK.FAILED
