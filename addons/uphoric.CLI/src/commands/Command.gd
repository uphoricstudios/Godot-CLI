extends Reference

const ARGUMENT = preload("res://addons/uphoric.CLI/src/arguments/Argument.gd")

var name: String = ""
var description: String = ""
var arguments: Array = []
var job: FuncRef = null


func _init(name: String, function: FuncRef) -> void:
	self.name = name
	self.job = function


func set_description(desc: String):
	description = desc
	return self


func add_argument(arg_name: String, type: int, desc: String = "", optional: bool = false):
	arguments.append(ARGUMENT.new(arg_name, type, desc, optional))
	return self


func execute(args: Array = []) -> void:
	job.call_funcv(args)
