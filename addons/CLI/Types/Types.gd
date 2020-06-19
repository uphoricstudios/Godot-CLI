extends Reference

const TypeString = preload("res://addons/CLI/Types/TypeString.gd")
const TypeInt = preload("res://addons/CLI/Types/TypeInt.gd")
const TypeBool = preload("res://addons/CLI/Types/TypeBool.gd")
const TypeFloat = preload("res://addons/CLI/Types/TypeFloat.gd")


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
