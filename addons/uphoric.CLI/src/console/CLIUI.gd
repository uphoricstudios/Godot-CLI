tool
extends Control

onready var line_edit: LineEdit = $VBox/LineEdit
onready var console: RichTextLabel = $VBox/RichTextLabel
onready var dir_label: Label = $VBox/DirectoryLabel


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


# anything to the right of the cursor
# is considered under it
func get_word_under_cursor() -> String:
	var word_index: Dictionary = get_word_index_under_cursor()
	var caret_pos: int = line_edit.caret_position
	var begin: int = word_index["begin"]
	var total: int = word_index["total"]
	
	if(begin == caret_pos):
		return ""
	
	return line_edit.text.substr(begin, total)


func set_caret_to_end() -> void:
	line_edit.caret_position = line_edit.text.length()


func set_caret_to_word_end() -> void:
	var word_index: Dictionary = get_word_index_under_cursor()
	line_edit.caret_position = word_index["end"] + 1


func replace_word_under_cursor(text: String) -> void:
	var word_index: Dictionary = get_word_index_under_cursor()
	var caret_pos: int = line_edit.caret_position
	var begin: int = word_index["begin"]
	var total: int = word_index["total"]
	
	if(begin == -1):
		line_edit.text = line_edit.text.insert(caret_pos, text)
		line_edit.caret_position = caret_pos
		set_caret_to_word_end()
		return
	
	var result: String = line_edit.text
	result.erase(begin, total)
	line_edit.text = result.insert(begin, text)
	line_edit.caret_position = caret_pos
	set_caret_to_word_end()

# research strategy pattern
func replace_path_under_cursor(text: String) -> void:
	var word_index: Dictionary = get_path_index_under_cursor()
	var caret_pos: int = line_edit.caret_position
	var begin: int = word_index["begin"]
	var total: int = word_index["total"]
	
	if(begin == -1):
		line_edit.text = line_edit.text.insert(caret_pos, text)
		line_edit.caret_position = caret_pos
		set_caret_to_path_end()
		return
	
	var result: String = line_edit.text
	result.erase(begin, total)
	line_edit.text = result.insert(begin, text)
	line_edit.caret_position = caret_pos
	set_caret_to_path_end()


func get_word_index_under_cursor() -> Dictionary:
	var result: Dictionary = {"begin": -1, "end": -1, "total": 0}
	var text: String = line_edit.text
	var caret_pos: int = line_edit.caret_position
	
	var begin: int = caret_pos
	while(begin > 0):
		var is_char: bool =  _is_text_char(text[begin - 1])
		if(!is_char):
			break
		begin -= 1
	
	var end: int = caret_pos
	while(end < text.length()):
		var is_char: bool = _is_text_char(text[end])
		if(!is_char):
			break
		end += 1
	
	if(begin == caret_pos):
		result["end"] = max(end - 1, 0)
		return result
	
	result["begin"] = begin
	result["end"] = max(end - 1, 0)
	result["total"] = end - begin
	return result


func get_path_index_under_cursor() -> Dictionary:
	var result: Dictionary = {"begin": -1, "end": -1, "total": 0}
	var text: String = line_edit.text
	var caret_pos: int = line_edit.caret_position
	
	var begin: int = caret_pos
	while(begin > 0):
		var is_char: bool =  _is_path_char(text[begin - 1])
		if(!is_char):
			break
		begin -= 1
	
	var end: int = caret_pos
	while(end < text.length()):
		var is_char: bool = _is_path_char(text[end])
		if(!is_char):
			break
		end += 1
	
	if(begin == caret_pos):
		result["end"] = max(end - 1, 0)
		return result
	
	result["begin"] = begin
	result["end"] = max(end - 1, 0)
	result["total"] = end - begin
	return result


func get_path_under_cursor() -> String:
	var word_index: Dictionary = get_path_index_under_cursor()
	var caret_pos: int = line_edit.caret_position
	var begin: int = word_index["begin"]
	var total: int = word_index["total"]
	
	if(begin == caret_pos):
		return ""
	
	return line_edit.text.substr(begin, total)


func set_caret_to_path_end() -> void:
	var word_index: Dictionary = get_path_index_under_cursor()
	line_edit.caret_position = word_index["end"] + 1


func is_char(c: String) -> bool:
	var small: bool = (ord(c) >= ord("a") && ord(c) <= ord("z"))
	var caps: bool = (ord(c) >= ord("A") && ord(c) <= ord("Z"))
	var sym: bool = (ord(c) == ord("_"))
	return (small || caps || sym)


func is_number(c: String) -> bool:
	return (ord(c) >= ord("0") && ord(c) <= ord("9"))


func _is_text_char(c: String) -> bool:
	return (is_char(c) || is_number(c))


func _is_path_char(c: String) -> bool:
	return (ord(c) == ord("/") || ord(c) == ord(":") || ord(c) == ord(".") || _is_text_char(c))
