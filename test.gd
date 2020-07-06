extends Node2D

onready var line_edit = $LineEdit

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("ui_accept")):
		var d: Dictionary = get_word_index_under_cursor()
		var begin: int = d["begin"]
		var end: int = d["end"]
		print(d)
		#print(get_word_under_cursor())
		print(replace_word_under_cursor("pudding"))
		print(line_edit.caret_position)
		#print(line_edit.text.substr(begin, end-begin))
		#print("begin: ", line_edit.text[begin])
		#print("end: ", line_edit.text[end-1])

func get_word_under_cursor() -> String:
	var word_index: Dictionary = get_word_index_under_cursor()
	var caret_pos: int = line_edit.caret_position
	var begin: int = word_index["begin"]
	var end: int = word_index["end"]
	
	if(begin == caret_pos):
		return ""
	
	return line_edit.text.substr(begin, end - begin)

func set_caret_to_end() -> void:
	line_edit.caret_position = line_edit.text.length()


func set_caret_to_word_end() -> void:
	var word_index: Dictionary = get_word_index_under_cursor()
	line_edit.caret_position = word_index["end"]


func replace_word_under_cursor(text: String) -> void:
	var word_index: Dictionary = get_word_index_under_cursor()
	var caret_pos: int = line_edit.caret_position
	var begin: int = word_index["begin"]
	var end: int = word_index["end"]
	
	if(begin == -1):
		line_edit.text = line_edit.text.insert(caret_pos, text)
		line_edit.caret_position = caret_pos
		set_caret_to_word_end()
		return
	
	var result: String = line_edit.text
	result.erase(begin, end - begin)
	line_edit.text = result.insert(begin, text)
	line_edit.caret_position = caret_pos
	set_caret_to_word_end()


func get_word_index_under_cursor() -> Dictionary:
	var result: Dictionary = {"begin": -1, "end": -1}
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
		result["end"] = end
		return result
	
	result["begin"] = begin
	result["end"] = end
	
	return result


func is_char(c: String) -> bool:
	var small: bool = (ord(c) >= ord("a") && ord(c) <= ord("z"))
	var caps: bool = (ord(c) >= ord("A") && ord(c) <= ord("Z"))
	var sym: bool = (ord(c) == ord("_"))
	return (small || caps || sym)


func is_number(c: String) -> bool:
	return (ord(c) >= ord("0") && ord(c) <= ord("9"))


func _is_text_char(c: String) -> bool:
	return (is_char(c) || is_number(c))
