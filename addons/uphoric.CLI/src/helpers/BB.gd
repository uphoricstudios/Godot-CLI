extends Reference

const ORANGE = "#e97500"
const RED = "red"
const GREEN = "green"
const YELLOW = "yellow"
const BLUE = "blue"
const AQUA = "aqua"
const GOLD = "#eb9500"
const L_BLUE = "#57b3ff"


func _init() -> void:
	pass 


static func color(text: String, color: String) -> String:
	var result: String = "[color={color}]{text}[/color]"
	return result.format({"color": color, "text": text})


static func bold(text: String) -> String:
	var result: String = "[b]{text}[/b]"
	return result.format({"text": text})


static func italics(text: String) -> String:
	var result: String = "[i]{text}[/i]"
	return result.format({"text": text})


static func underline(text: String) -> String:
	var result: String = "[u]{text}[/u]"
	return result.format({"text": text})


static func center(text: String) -> String:
	var result: String = "[center]{text}[/center]"
	return result.format({"text": text})


static func right(text: String) -> String:
	var result: String = "[right]{text}[/right]"
	return result.format({"text": text})


static func strike(text: String) -> String:
	var result: String = "[s]{text}[/s]"
	return result.format({"text": text})


static func code(text: String) -> String:
	var result: String = "[code]{text}[/code]"
	return result.format({"text": text})


static func fill(text: String) -> String:
	var result: String = "[fill]{text}[/fill]"
	return result.format({"text": text})


static func indent(text: String) -> String:
	var result: String = "[indent]{text}[/indent]"
	return result.format({"text": text})


static func url(text: String, link: String = "") -> String:
	if(link.empty()):
		var result: String = "[url]{text}[/url]"
		return result.format({"text": text})
	var result: String = "[url={link}]{text}[/url]"
	return result.format({"text": text, "link": link})


static func img(path: String, width: int = -1, height: int = -1) -> String:
	if(width == -1 && height == -1):
		var result: String = "[img]{path}[/img]"
		return result.format({"path": path})
	
	elif(width > 0 && height == -1):
		var result: String = "[img={width}]{path}[/img]"
		return result.format({"path": path, "width": str(width)})
	
	elif(width > 0 && height > 0):
		var result: String = "[img={width}x{height}]{path}[/img]"
		return result.format({
			"path": path, 
			"width": str(width),
			"height": str(height)
		})
	
	return ""


static func font(text: String, path: String) -> String:
	var result: String = "[font={path}]{text}[/font]"
	return result.format({"text": text, "path": path})


static func cell(text: String) -> String:
	var result: String = "[cell]{text}[/cell]"
	return result.format({"text": text})


static func table(columns: int, cells: Array) -> String:
	var result: String = "[table={columns}]"
	result = result.format({"columns": columns})
	
	for cell in cells:
		result += cell
	
	result += "[/table]"
	return result
