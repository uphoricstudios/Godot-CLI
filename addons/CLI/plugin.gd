tool
extends EditorPlugin

const cli_ui_scene = preload('res://addons/CLI/Console/CLIUI.tscn')
var cli_ui
var singleton_name = 'CLI'
var console_script = 'res://addons/CLI/Console/CLI.gd'
var cli_button: ToolButton
var input_map_name: String = "cli_hotkey"


func _enter_tree() -> void:
	var ev = InputEventKey.new()
	ev.scancode = KEY_QUOTELEFT
	ev.alt = true
	InputMap.add_action(input_map_name)
	InputMap.action_add_event(input_map_name, ev)
	
	add_autoload_singleton(singleton_name, console_script)
	cli_ui = cli_ui_scene.instance()
	cli_button = add_control_to_bottom_panel(cli_ui, 'CLI')
	cli_button.connect("toggled", cli_ui, "_on_cli_focus")


func _exit_tree() -> void:
	remove_autoload_singleton(singleton_name)
	remove_control_from_bottom_panel(cli_ui)
	InputMap.erase_action(input_map_name)
	if(cli_ui != null):
		cli_ui.queue_free()

func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("cli_hotkey")):
		# Until Godot 4.0 fixes bottom panel while in distraction free mode
		cli_button.pressed = !cli_button.pressed
	pass
