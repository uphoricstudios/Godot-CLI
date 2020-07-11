tool
extends Node

signal user_input

const BB = preload("res://addons/uphoric.CLI/src/helpers/BB.gd")
const PARSER = preload("res://addons/uphoric.CLI/src/helpers/InputParser.gd")
const ARGUMENT = preload("res://addons/uphoric.CLI/src/arguments/Argument.gd")
const HOTKEYS = preload("res://addons/uphoric.CLI/src/helpers/Hotkeys.gd")
const CONFIG_PATH: String = "res://addons/uphoric.CLI/plugin.cfg"

var current_dir: String
var _expect_input: bool = false
var _cli_ui
var _history
var _command_list
var _auto


func _ready() -> void:
	_history = load("res://addons/uphoric.CLI/src/helpers/History.gd").new()
	_command_list = load("res://addons/uphoric.CLI/src/commands/CommandList.gd").new()
	_auto = load("res://addons/uphoric.CLI/src/helpers/AutoComplete.gd").new()
	current_dir = ProjectSettings.globalize_path("res://")


func input():
	_expect_input = true
	return self


func add_command(name: String, function: FuncRef):
	var cmd_name: String = name.to_lower()
	var check: int = _command_list.add_command(cmd_name, function)
	if(check == _command_list.CHECK.OK):
		return _command_list.get_command(cmd_name)
	elif(check == _command_list.CHECK.ALREADY_EXISTS):
		error(BB.color(cmd_name, BB.GOLD) + " could not be added.")
		error("A command with that name already exists.")


func write(text: String) -> void:
	_cli_ui.console.append_bbcode(text)
	_cli_ui.console.newline()


func clear() -> void:
	_cli_ui.console.clear()


func newline(num_lines: int = 1) -> void:
	if(num_lines >= 1):
		for i in num_lines:
			_cli_ui.console.newline()


func error(text: String) -> void:
	write("+ " + BB.color(text, BB.RED))


func reload_commands() -> void:
	_command_list.reload_commands()
	_auto.set_auto("commands", _command_list.get_command_names())
	_auto.set_auto("path", current_dir)


func get_current_directory() -> String:
	return current_dir


func change_working_directory(path: String) -> bool:
	var dir: Directory = Directory.new()
	if(dir.open(path) == OK):
		current_dir = ProjectSettings.globalize_path(dir.get_current_dir())
		_cli_ui.dir_label.text = current_dir
		_auto.set_auto("path", current_dir)
		return true
	return false


func _on_cli_input_entered(text: String) -> void:
	# Returns input to commands that require them
	if(_expect_input):
		_expect_input = false
		_cli_ui.console.append_bbcode("=> " + BB.color(text, BB.AQUA))
		newline()
		_cli_ui.line_edit.clear()
		emit_signal("user_input", text)
		return
	
	_cli_ui.console.append_bbcode(">> " + BB.color(text, BB.AQUA))
	_history.push(text)
	newline()
	_cli_ui.line_edit.clear()
	_parse_input(text)


func _on_cli_input_changed(text: String) -> void:
	_history.reset_index()


func _on_cli_key_pressed(event: InputEvent) -> void:
	if(event.is_action_pressed(HOTKEYS.UP)):
		var history_str: String = _history.next()
		_cli_ui.line_edit.text = history_str
		_cli_ui.set_caret_to_end()
	
	if(event.is_action_pressed(HOTKEYS.DOWN)):
		var history_str: String = _history.previous()
		_cli_ui.line_edit.text = history_str
		_cli_ui.set_caret_to_end()
	
	if(event.is_action_pressed(HOTKEYS.TAB)):
		var input: String = _cli_ui.line_edit.text
		var current: String = _cli_ui.get_path_under_cursor()
		var auto: String = _auto.get_auto(input, current)
		
		if(auto.empty()):
			return
		
		_cli_ui.replace_path_under_cursor(auto)


func _add_cli_ui_instance(cli_ui) -> void:
	_cli_ui = cli_ui
	_cli_ui.line_edit.connect("text_changed", self, "_on_cli_input_changed")
	_cli_ui.line_edit.connect("text_entered", self, "_on_cli_input_entered")
	_cli_ui.line_edit.connect("gui_input", self, "_on_cli_key_pressed")
	_start_up()


func _start_up() -> void:
	_cli_ui.dir_label.text = current_dir
	var config := ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	var version: String = "0.0.0"
	
	if(err == OK):
		version = config.get_value("plugin", "version")
	
	write("Uphoric Studios")
	write("Godot CLI " + version)
	newline()
	reload_commands()


func _parse_input(text: String) -> void:
	if(text.empty()):
		return
	
	var not_found_error: String = "The command {cmd_name} could not be found. Misspelt?"
	var num_arg_error: String = "Incorrect number of arguments, {args_num} expected."
	var input: Array = PARSER.parse(text)
	var cmd_name: String = input.pop_front().to_lower()
	
	if(!_command_list.has(cmd_name)):
		error(not_found_error.format({"cmd_name": BB.color(cmd_name, BB.GOLD)}))
		return
	
	var cmd = _command_list.get_command(cmd_name)
	
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
				{"ori_arg": BB.color(ori_arg, BB.AQUA)}
				))
			error(BB.color(cmd_name, BB.GOLD) + " expects:")
			for arg in cmd.arguments:
				error(arg.describe())
			return
		else:
			normalized_args.append(cmd.arguments[i].get_value())
		i += 1
	
	cmd.execute(normalized_args)
