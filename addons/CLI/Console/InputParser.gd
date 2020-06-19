extends Reference

static func parse(text: String) -> Array:
	var result: Array = []
	var to_process: String = text.strip_edges()
	var open_double_quote: bool = false
	var open_single_quote: bool = false
	var word: String = ""
	var input_string: String = ""
	
	for ch in to_process:
		if(ch == " " && !word.empty()):
			result.append(word)
			word = ""
		elif(ch == '"' && !open_single_quote):
			open_double_quote = !open_double_quote
		elif(ch == "'" && !open_double_quote):
			open_single_quote = !open_single_quote
		else:
			if(open_double_quote || open_single_quote):
				input_string += ch
			else:
				if(!input_string.empty()):
					result.append(input_string)
					input_string = ""
				word += ch
	
	# Make sure to get last words
	if(!word.empty()):
		result.append(word)
	if(!input_string.empty()):
		result.append(input_string)
	
	return result
