tool
extends EditorPlugin

const CLI_SCRIPT: String = "res://addons/skelm.CLI/src/console/CLI.gd"
const HOTKEY_CLI: String = "hotkey_cli"
const HOTKEY_UP: String = "hotkey_up"
const HOTKEY_DOWN: String = "hotkey_down"
const SINGLETON_NAME: String = "CLI"
const UI_SCENE = preload("res://addons/skelm.CLI/src/console/CLIUI.tscn")
#const CLI_ICON = preload("res://addons/skelm.CLI/cli_icon.svg")

var cli_button: ToolButton
var cli_ui


func _enter_tree() -> void:
	add_autoload_singleton(SINGLETON_NAME, CLI_SCRIPT)
	_set_up_hotkeys()
	cli_ui = UI_SCENE.instance()
	cli_button = add_control_to_bottom_panel(cli_ui, "CLI")
	cli_button.connect("toggled", cli_ui, "_on_cli_focus")


func _exit_tree() -> void:
	remove_autoload_singleton(SINGLETON_NAME)
	remove_control_from_bottom_panel(cli_ui)
	InputMap.erase_action(HOTKEY_CLI)
	InputMap.erase_action(HOTKEY_UP)
	InputMap.erase_action(HOTKEY_DOWN)
	if(cli_ui != null):
		cli_ui.queue_free()


func get_plugin_name() -> String:
	return "CLI"


#func get_plugin_icon():
#	return CLI_ICON


func _input(event: InputEvent) -> void:
	if(event.is_action_pressed(HOTKEY_CLI)):
		# Until Godot 4.0 fixes bottom panel while in distraction free mode
		cli_button.pressed = !cli_button.pressed
	pass


func _set_up_hotkeys() -> void:
	var ev = InputEventKey.new()
	ev.scancode = KEY_QUOTELEFT
	ev.alt = true
	InputMap.add_action(HOTKEY_CLI)
	InputMap.action_add_event(HOTKEY_CLI, ev)
	
	ev = InputEventKey.new()
	ev.scancode = KEY_UP
	InputMap.add_action(HOTKEY_UP)
	InputMap.action_add_event(HOTKEY_UP, ev)
	
	ev = InputEventKey.new()
	ev.scancode = KEY_DOWN
	InputMap.add_action(HOTKEY_DOWN)
	InputMap.action_add_event(HOTKEY_DOWN, ev)
