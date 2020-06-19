tool
extends Node


signal user_input

var COLORS
var _commands: Dictionary = {}
var _loaded_commands: Array = []
var _Parser
var _Argument
var _Command
var _cli_ui

var expect_input: bool = false

func _ready() -> void:
	COLORS = load('res://addons/CLI/Console/Colors.gd')
	_Parser = load("res://addons/CLI/Console/InputParser.gd")
	_Argument = load("res://addons/CLI/Arguments/Argument.gd")
	_Command = load("res://addons/CLI/Commands/Command.gd")

func input():
	expect_input = true
	return self


func add_command(name: String, function: FuncRef):
	var cmd_name: String = name.to_lower()
	var cmd = _Command.new(cmd_name, function)
	if(!_commands.has(cmd_name)):
		_commands[cmd.name] = cmd
		return cmd
	error(color_text(cmd_name, COLORS.GOLD) + " could not be added.")
	error("A command with that name already exists.")
	return cmd


func write(text: String) -> void:
	_cli_ui.console.append_bbcode(text)
	_cli_ui.console.newline()


func clear() -> void:
	_cli_ui.console.clear()


func newline() -> void:
	_cli_ui.console.newline()


func color_text(text: String, color: String) -> String:
	var result: String = "[color={color}]{text}[/color]"
	return result.format({"color": color, "text": text})


func error(text: String) -> void:
	write("+ " + color_text(text, COLORS.RED))


func _on_cli_input_entered(text: String) -> void:
	# Returns input to commands that require them
	if(expect_input):
		expect_input = false
		_cli_ui.console.append_bbcode("=> " + color_text(text, COLORS.AQUA))
		newline()
		_cli_ui.line_edit.clear()
		emit_signal("user_input", text)
		return
	
	_cli_ui.console.append_bbcode(">> " + color_text(text, COLORS.AQUA))
	newline()
	_cli_ui.line_edit.clear()
	_parse_input(text)


func _on_cli_input_changed(text: String) -> void:
	pass


func _add_cli_ui_instance(cli_ui) -> void:
	_cli_ui = cli_ui
	_cli_ui.line_edit.connect("text_changed", self, "_on_cli_input_changed")
	_cli_ui.line_edit.connect("text_entered", self, "_on_cli_input_entered")
	_start_up()


func _start_up() -> void:
	var gd_version: String = "Godot {ma}.{mi}.{pa}"
	write("Welcome user!")
	write(gd_version.format({
		"ma": Engine.get_version_info()["major"],
		"mi": Engine.get_version_info()["minor"],
		"pa": Engine.get_version_info()["patch"]
	}))
	
	_load_commands("res://addons/CLI/load/")
	


func _parse_input(text: String) -> void:
	if(text.empty()):
		return
	
	var not_found_error: String = "The command {cmd_name} could not be found. Misspelled?"
	var num_arg_error: String = "Incorrect number of arguments, {args_num} expected."
	
	var input: Array = _Parser.parse(text)
	var cmd_name: String = input.pop_front().to_lower()
	
	# Check if commmand exists
	if(!_commands.has(cmd_name)):
		error(not_found_error.format({"cmd_name": cmd_name}))
		return
	
	var cmd = _commands[cmd_name]
	
	# Check if correct number of arguments given
	if(len(input) != len(cmd.arguments)):
		error(num_arg_error.format({"args_num": len(cmd.arguments)}))
		return
	
	# Check if arguments are valid
	var normalized_args: Array = []
	
	var i: int = 0
	while(i < len(input)):
		var check: int = cmd.arguments[i].set_value(input[i])
		if(check == _Argument.CHECK.FAILED):
			var ori_arg: String = cmd.arguments[i].get_original_value()
			error("Unexpected argument '{ori_arg}'".format(
				{"ori_arg": color_text(ori_arg, COLORS.AQUA)}
				))
			error(color_text(cmd_name, COLORS.GOLD) + " expects:")
			for arg in cmd.arguments:
				error(arg.describe())
			return
		else:
			normalized_args.append(cmd.arguments[i].get_value())
		i += 1
	
	cmd.execute(normalized_args)


func _load_commands(path) -> void:
	var dir := Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if(file_name.ends_with(".gd")):
				var command_script = load(path+file_name)
				_loaded_commands.append(command_script.new())
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
