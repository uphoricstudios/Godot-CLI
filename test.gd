extends Node2D

onready var line_edit: LineEdit = $LineEdit
onready var box: ColorRect = $ColorRect
var boxh: float = 100
var l: Label
var of: Vector2 = Vector2(15, -5)

func _ready() -> void:
	box.rect_size = Vector2(boxh, boxh)
	l = Label.new()
	add_child(l)
	pass

func _process(delta: float) -> void:
	var mouse: Vector2 = get_global_mouse_position()
	l.text = str(mouse)
	l.set_global_position(mouse + Vector2(5,5))

func get_complete() -> Vector2:
	var result: Vector2 = Vector2()
	# box
	var sb: StyleBox = line_edit.get_stylebox("normal")
	var sboffset: Vector2 = sb.get_offset()
	var lp: Vector2 = line_edit.get_global_rect().position
#	print(sb.get_center_size())
#	print(sb.get_offset() + lp)
	
	# text
	var font: Font = line_edit.get_font("font")
	var tt: int = max(line_edit.caret_position - 1, 0)
	var spos: Vector2 = font.get_string_size(line_edit.text.substr(0, tt))
#	print((sb.get_offset() + lp).x + spos.x)
	result = Vector2(sb.get_offset() + lp + spos)
	return result


func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("ui_accept")):
		var bpos: Vector2 = get_complete()
		box.set_global_position(bpos + of)
	if(event.is_action_pressed("ui_up")):
		get_tree().set_input_as_handled()
		replace_word_under_cursor("pudding")
	if(event.is_action_pressed("ui_down")):
		box.set_global_position(Vector2(0,0))
	

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


func is_char(c: String) -> bool:
	var small: bool = (ord(c) >= ord("a") && ord(c) <= ord("z"))
	var caps: bool = (ord(c) >= ord("A") && ord(c) <= ord("Z"))
	var sym: bool = (ord(c) == ord("_"))
	return (small || caps || sym)


func is_number(c: String) -> bool:
	return (ord(c) >= ord("0") && ord(c) <= ord("9"))


func _is_text_char(c: String) -> bool:
	return (is_char(c) || is_number(c))
