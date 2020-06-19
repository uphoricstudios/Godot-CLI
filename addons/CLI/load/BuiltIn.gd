extends Reference

func _init() -> void:
	
	CLI.add_command('np', funcref(self, 'pudding'))\
	.set_description("Name and place!")\
	.add_argument('name', TYPE_STRING, "Name of the user.")\
	.add_argument('place', TYPE_STRING, "Where the user lives.")
	
	CLI.add_command('addi', funcref(self, 'addint'))\
	.set_description("adds ints")\
	.add_argument('first', TYPE_INT, "First integer to add.")\
	.add_argument('second', TYPE_INT, "Second integer to add.")
	
	CLI.add_command('addf', funcref(self, 'addfloat'))\
	.set_description("add floats")\
	.add_argument('name', TYPE_REAL)\
	.add_argument('place', TYPE_REAL)
	
	CLI.add_command('bool', funcref(self, 'testbool'))\
	.set_description("add floats")\
	.add_argument('name', TYPE_BOOL)\
	.add_argument('name', TYPE_BOOL)\
	
	CLI.add_command('get', funcref(self, 'get_name'))\
	.set_description("gets name and outputs it")
	
	CLI.add_command('get', funcref(self, 'get_name'))\
	.set_description("gets name and outputs it")


func pudding(name: String, place: String):
	CLI.write("My name is " + name + " and I live in " + place + ".")

func addint(a: int, b: int):
	CLI.write(str(a+b))
	
func addfloat(a: float, b: float):
	CLI.write(str(a+b))

func testbool(a: bool, b: bool):
	if(a):
		CLI.write("LIES")
	else:
		CLI.write("MORE LIES LIES LIES")

func get_name():
	CLI.write("What is your first name?")
	var first = yield(CLI.input(), "user_input")
	CLI.write("What is your last name?")
	var last = yield(CLI.input(), "user_input")
	CLI.write("Your name is " + first + " " + last)
