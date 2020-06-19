extends Reference

var name: String = ""
var description: String = ""
var arguments: Array = []
var job: FuncRef = null
var _Argument


func _init(name: String, function: FuncRef) -> void:
	self.name = name
	self.job = function
	_Argument = load("res://addons/skelm.CLI/src/arguments/Argument.gd")


func set_description(desc: String):
	description = desc
	return self


func add_argument(arg_name: String, type: int, desc: String = ""):
	arguments.append(_Argument.new(arg_name, type, desc))
	return self


func execute(args: Array = []) -> void:
	job.call_funcv(args)
