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


func get_word_under_cursor() -> String:
	var text: String = line_edit.text
	var caret_pos: int = line_edit.caret_position
	
	var left: int = caret_pos
	while(left > 0):
		var is_char: bool =  _is_text_char(text[left - 1])
		if(!is_char):
			break
		left -= 1
	
	var right: int = caret_pos
	while(right < text.length()):
		var is_char: bool = _is_text_char(text[right])
		if(!is_char):
			break
		right += 1
	
	if(left == caret_pos):
		return ""
	
	return text.substr(left, right-left)

func set_caret_to_end() -> void:
	line_edit.caret_position = line_edit.text.length()

func is_char(c: String) -> bool:
	var small: bool = (ord(c) >= ord("a") && ord(c) <= ord("z"))
	var caps: bool = (ord(c) >= ord("A") && ord(c) <= ord("Z"))
	var sym: bool = (ord(c) == ord("_"))
	return (small || caps || sym)


func is_number(c: String) -> bool:
	return (ord(c) >= ord("0") && ord(c) <= ord("9"))


func _is_text_char(c: String) -> bool:
	return (is_char(c) || is_number(c))

