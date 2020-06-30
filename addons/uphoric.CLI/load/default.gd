extends Reference

func _init() -> void:
	
	CLI.add_command('reload', funcref(self, 'reload'))\
	.set_description("Reloads all commands.")\
	
	CLI.add_command('clear', funcref(self, 'clear'))\
	.set_description("Clears the console.")\
	
	CLI.add_command('random', funcref(self, 'random'))\
	.set_description("Generates a random integer.")\


func reload():
	CLI.reload_commands()
	CLI.clear()
	CLI.write("CLI successfully reloaded.")


func clear():
	CLI.clear()


func random():
	var rand := RandomNumberGenerator.new()
	CLI.write(str(rand.randi()))


#func get_name():
#	CLI.write("What is your first name?")
#	var first = yield(CLI.input(), "user_input")
#	CLI.write("What is your last name?")
#	var last = yield(CLI.input(), "user_input")
#	CLI.write("Your name is " + first + " " + last)
