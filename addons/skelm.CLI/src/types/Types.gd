extends Reference

const TypeString = preload("res://addons/skelm.CLI/src/types/TypeString.gd")
const TypeInt = preload("res://addons/skelm.CLI/src/types/TypeInt.gd")
const TypeBool = preload("res://addons/skelm.CLI/src/types/TypeBool.gd")
const TypeFloat = preload("res://addons/skelm.CLI/src/types/TypeFloat.gd")


func get_type(value):
	match(value):
		TYPE_STRING:
			return TypeString.new()
		TYPE_INT:
			return TypeInt.new()
		TYPE_BOOL:
			return TypeBool.new()
		TYPE_REAL:
			return TypeFloat.new()
