tool
extends Control

onready var line_edit: LineEdit = $VBox/LineEdit
onready var console: RichTextLabel = $VBox/RichTextLabel


func _ready() -> void:
	_set_up_console()


func _set_up_console() -> void:
	yield(CLI, "ready")
	CLI._add_cli_ui_instance(self)


func _on_cli_focus(pressed: bool) -> void:
	if(pressed):
		line_edit.grab_focus()
	else:
		line_edit.release_focus()
