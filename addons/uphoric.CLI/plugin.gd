tool
extends EditorPlugin

const CLI_SCRIPT: String = "res://addons/uphoric.CLI/src/console/CLI.gd"
const SINGLETON_NAME: String = "CLI"
const UI_SCENE = preload("res://addons/uphoric.CLI/src/console/CLIUI.tscn")
const HOTKEYS = preload("res://addons/uphoric.CLI/src/console/Hotkeys.gd")
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
	InputMap.erase_action(HOTKEYS.OPEN_CLI)
	InputMap.erase_action(HOTKEYS.UP)
	InputMap.erase_action(HOTKEYS.DOWN)
	InputMap.erase_action(HOTKEYS.TAB)
	cli_button.disconnect("toggled", cli_ui, "_on_cli_focus")
	remove_autoload_singleton(SINGLETON_NAME)
	remove_control_from_bottom_panel(cli_ui)
	if(cli_ui != null):
		cli_ui.queue_free()


func get_plugin_name() -> String:
	return "CLI"


#func get_plugin_icon():
#	return CLI_ICON


func _input(event: InputEvent) -> void:
	if(event.is_action_pressed(HOTKEYS.OPEN_CLI)):
		# Until Godot 4.0 fixes bottom panel while in distraction free mode
		cli_button.pressed = !cli_button.pressed


func _set_up_hotkeys() -> void:
	var ev = InputEventKey.new()
	ev.scancode = KEY_QUOTELEFT
	ev.alt = true
	InputMap.add_action(HOTKEYS.OPEN_CLI)
	InputMap.action_add_event(HOTKEYS.OPEN_CLI, ev)
	
	ev = InputEventKey.new()
	ev.scancode = KEY_UP
	InputMap.add_action(HOTKEYS.UP)
	InputMap.action_add_event(HOTKEYS.UP, ev)
	
	ev = InputEventKey.new()
	ev.scancode = KEY_DOWN
	InputMap.add_action(HOTKEYS.DOWN)
	InputMap.action_add_event(HOTKEYS.DOWN, ev)
	
	ev = InputEventKey.new()
	ev.scancode = KEY_TAB
	InputMap.add_action(HOTKEYS.TAB)
	InputMap.action_add_event(HOTKEYS.TAB, ev)
