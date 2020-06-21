tool
extends Node

signal user_input

const COLORS = preload("res://addons/skelm.CLI/src/console/Colors.gd")
const PARSER = preload("res://addons/skelm.CLI/src/console/InputParser.gd")
const ARGUMENT = preload("res://addons/skelm.CLI/src/arguments/Argument.gd")
const COMMAND = preload("res://addons/skelm.CLI/src/commands/Command.gd")
const HOTKEYS = preload("res://addons/skelm.CLI/src/console/Hotkeys.gd")
const LOAD_PATH: String = "res://addons/skelm.CLI/load/"
const CONFIG_PATH: String = "res://addons/skelm.CLI/plugin.cfg"

var _commands: Dictionary = {}
var _loaded_commands: Dictionary = {}
var _expect_input: bool = false
var _cli_ui
var _history


func _ready() -> void:
	_history = load("res://addons/skelm.CLI/src/console/History.gd").new()


func input():
	_expect_input = true
	return self


func add_command(name: String, function: FuncRef):
	var cmd_name: String = name.to_lower()
	var cmd = COMMAND.new(cmd_name, function)
	if(!_commands.has(cmd_name)):
		_commands[cmd_name] = cmd
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
	if(_expect_input):
		_expect_input = false
		_cli_ui.console.append_bbcode("=> " + color_text(text, COLORS.AQUA))
		newline()
		_cli_ui.line_edit.clear()
		emit_signal("user_input", text)
		return
	
	_cli_ui.console.append_bbcode(">> " + color_text(text, COLORS.AQUA))
	_history.push(text)
	newline()
	_cli_ui.line_edit.clear()
	_parse_input(text)


func _on_cli_input_changed(text: String) -> void:
	_history.reset()


func _on_cli_key_pressed(event: InputEvent) -> void:
	if(event.is_action_pressed(HOTKEYS.UP)):
		var history_str: String = _history.next()
		_cli_ui.line_edit.text = history_str
		_cli_ui.line_edit.caret_position = history_str.length()
		
	if(event.is_action_pressed(HOTKEYS.DOWN)):
		var history_str: String = _history.previous()
		_cli_ui.line_edit.text = history_str
		_cli_ui.line_edit.caret_position = history_str.length()


func _add_cli_ui_instance(cli_ui) -> void:
	_cli_ui = cli_ui
	_cli_ui.line_edit.connect("text_changed", self, "_on_cli_input_changed")
	_cli_ui.line_edit.connect("text_entered", self, "_on_cli_input_entered")
	_cli_ui.line_edit.connect("gui_input", self, "_on_cli_key_pressed")
	_start_up()


func _start_up() -> void:
	var config := ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	var version: String = "0.0.0"
	if(err == OK):
		version = config.get_value("plugin", "version")
	
	write("Skelm Studios")
	write("Godot CLI " + version)
	newline()
	reload_commands()


func reload_commands() -> void:
	for key in _loaded_commands:
		if(key != "default.gd"):
			_loaded_commands.erase(key)
	
	_commands.clear()
	
	var dir := Directory.new()
	if dir.open(LOAD_PATH) == OK:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		
		while !file_name.empty():
			if(file_name.ends_with(".gd")):
				if(!_loaded_commands.has(file_name)):
					var command_script = load(LOAD_PATH + file_name)
					_loaded_commands[file_name] = command_script.new()
			
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")


func _parse_input(text: String) -> void:
	if(text.empty()):
		return
	
	var not_found_error: String = "The command {cmd_name} could not be found. Misspelled?"
	var num_arg_error: String = "Incorrect number of arguments, {args_num} expected."
	var input: Array = PARSER.parse(text)
	var cmd_name: String = input.pop_front().to_lower()
	
	if(!_commands.has(cmd_name)):
		error(not_found_error.format({"cmd_name": cmd_name}))
		return
	
	var cmd = _commands[cmd_name]
	
	if(len(input) != len(cmd.arguments)):
		error(num_arg_error.format({"args_num": len(cmd.arguments)}))
		return
	
	var normalized_args: Array = []
	
	var i: int = 0
	while(i < len(input)):
		var check: int = cmd.arguments[i].set_value(input[i])
		if(check == ARGUMENT.CHECK.FAILED):
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
