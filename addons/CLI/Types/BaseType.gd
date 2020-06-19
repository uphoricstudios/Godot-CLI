extends Reference

enum CHECK {
	OK,
	FAILED
}

var _name: String
var _type: int = -1
var _rematch
var _normalized_value

func normalize(value: String) -> int:
	return CHECK.FAILED


func get_normalized_value():
	return self._normalized_value
