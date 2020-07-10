extends Reference

var platform: String = OS.get_name()

func _init() -> void:
	platform = OS.get_name()
	var terminal_name: String
	
	if(platform == "Windows"):
		terminal_name = "powershell"
		pass
	
	elif(platform == "X11"):
		pass
	
	elif(platform == "OSX"):
		pass
	
	CLI.add_command('reload', funcref(self, 'reload'))\
	.set_description("Reloads all commands, and reloads most of the CLIs state.")
	
	CLI.add_command('clear', funcref(self, 'clear'))\
	.set_description("Clears the console.")
	
	CLI.add_command('ls', funcref(self, 'ls'))\
	.set_description("Lists the current directory's contents.")
	
	CLI.add_command('cd', funcref(self, 'cd'))\
	.set_description("Changes the current working directory.")\
	.add_argument("path", TYPE_STRING, "Path to directory.")
	
	CLI.add_command('opendir', funcref(self, 'opendir'))\
	.set_description("Opens platforms file explorer to current working directory.")
	
	CLI.add_command('mkdir', funcref(self, 'mkdir'))\
	.set_description("Creates directory at a given path.")\
	.add_argument("path", TYPE_STRING, "Path to directory.")
	
	CLI.add_command('cwd', funcref(self, 'cwd'))\
	.set_description("Shows current working directory.")
	
	CLI.add_command('backup', funcref(self, 'backup'))\
	.set_description("Backs up current Godot project to a compressed file. The file name will be the date and time of backup.")\
	
	CLI.add_command(terminal_name, funcref(self, 'native_terminal'))\
	.set_description("Sends commands to the platform's native terminal. All commands will be non-blocking and will not return an output. The use of this command is discouraged, it's only meant for things that cannot be done with the CLI.")\
	.add_argument("args", TYPE_STRING, "Arguments to be passed to the terminal.")
	
	CLI.add_command('commands', funcref(self, 'commands'))\
	.set_description("Lists all available commands.")
	
	CLI.add_command('help', funcref(self, 'help'))\
	.set_description("Shows command description and arguments.")\
	.add_argument("command", TYPE_STRING, "Name of command to get help for.")
	

func reload() -> void:
	CLI.reload_commands()
	CLI.clear()
	CLI.write("CLI successfully reloaded.")


func clear() -> void:
	CLI.clear()


# add config to allow to show hidden
func ls() -> void:
	var dir: Directory = Directory.new()
	var file := File.new()
	var current_dir: String = CLI.get_current_directory()
	var hide_hidden_files: bool = true
	var results: String = "[table=3]\n"
	results += "[cell][right]Bytes[/right][/cell]\n"
	results += "[cell] [/cell]\n"
	results += "[cell]Name[/cell]\n"
	results += "[cell][right]=====[/right][/cell]\n"
	results += "[cell]|[/cell]\n"
	results += "[cell]=====[/cell]\n"
	
	if dir.open(current_dir) == OK:
		dir.list_dir_begin(true, hide_hidden_files)
		var current: String = dir.get_next()
		
		while(!current.empty()):
			if(dir.file_exists(current)):
				file.open(current_dir + current, File.READ)
				results += "[cell][right]" + str(file.get_len()) + "[/right][/cell]\n"
				results += "[cell]|[/cell]\n"
				results += "[cell]" + current + "[/cell]\n"
				file.close()
			
			else:
				results += "[cell] [/cell]\n"
				results += "[cell]|[/cell]\n"
				results += "[cell]" + current + "[/cell]\n"
			
			current = dir.get_next()
	
	results += "[/table]\n"
	CLI.newline()
	CLI.write(results)


func cd(path: String) -> void:
	if(CLI.change_working_directory(path)):
		CLI.write("Directory: " + CLI.get_current_directory())
		return
	CLI.error("Cannot find path to '" + path + "' because it does not exist.")


func opendir() -> void:
	if(platform == "Windows"):
		OS.execute("explorer", ["."], false)
		CLI.write("Opening directory...")
	
	elif(platform == "X11"):
		pass
	
	elif(platform == "OSX"):
		pass


func mkdir(path: String) -> void:
	var dir: Directory = Directory.new()
	if(dir.open(CLI.get_current_directory()) == OK):
		if(dir.make_dir_recursive(path) == OK):
			CLI.write("Directory created.")
		else:
			CLI.error("Directory could not be created.")


func cwd() -> void:
	CLI.write(CLI.get_current_directory())


func backup() -> void:
	var project_dir: String = ProjectSettings.globalize_path("res://")
	var dir: Directory = Directory.new()
	
	if(dir.open(project_dir) == OK):
		if(!dir.dir_exists("backups")):
			if(dir.make_dir("backups") != OK):
				CLI.error("Backup could not be created.")
				return
	
	var backup_dir: String = ProjectSettings.globalize_path("res://backups") + "/"
	var backup_name: String = "{day}-{month}-{year}-[{hour}{minute}{second}].zip"
	var datetime: Dictionary = OS.get_datetime()
	var file_types: String = ""

	backup_name = backup_name.format({
		"day": datetime["day"],
		"month": datetime["month"],
		"year": datetime["year"],
		"hour": datetime["hour"],
		"minute": datetime["minute"],
		"second": datetime["second"]
	})
	
	file_types += "*.gd,"
	file_types += "*.tscn,"
	file_types += "*.scn,"
	file_types += "*.tres,"
	file_types += "*.cfg,"
	file_types += "*.json,"
	file_types += "*.xml,"
	file_types += "*.ini,"
	file_types += "*.cs,"
	file_types += "*.cpp,"
	file_types += "*.h,"
	file_types += "*.md,"
	file_types += "*.txt" # don't forget the comma if expanded
	
	backup_dir += backup_name
	var args: String = "Get-ChildItem -Path {project_dir} -Recurse -Include {file_types} | Compress-Archive -DestinationPath {backup_dir}"
	
	args = args.format({
		"project_dir": project_dir,
		"file_types": file_types,
		"backup_dir": backup_dir
	})
	
	if(platform == "Windows"):
		OS.execute("powershell.exe", [args], false)
		CLI.write("Backup complete.")
	
	elif(platform == "X11"):
		pass
	
	elif(platform == "OSX"):
		pass


func native_terminal(args: String) -> void:
	if(platform == "Windows"):
		OS.execute("powershell.exe", [args], false)
		pass
	
	elif(platform == "X11"):
		pass
	
	elif(platform == "OSX"):
		pass


func commands() -> void:
	var command_list: Dictionary = CLI._command_list.get_commands()
	var results: String = "[table=3]\n"
	results += "[cell][right]Name[/right][/cell]\n"
	results += "[cell] [/cell]\n"
	results += "[cell]Description[/cell]\n"
	results += "[cell][right]=====[/right][/cell]\n"
	results += "[cell]|[/cell]\n"
	results += "[cell]=====[/cell]\n"
	
	for key in command_list:
		results += "[cell][right]" + key + "[/right][/cell]\n"
		results += "[cell]|[/cell]\n"
		results += "[cell]" + command_list[key].description + "[/cell]\n"
	
	results += "[/table]\n"
	CLI.newline()
	CLI.write(results)


func help(command: String) -> void:
	var command_list = CLI._command_list
	
	if(!command_list.has(command)):
		CLI.error("The command '" + command + "' does not exist.")
		return
	
	var cmd = command_list.get_command(command)

	CLI.newline()
	CLI.write(cmd.name + ":")
	CLI.newline()
	CLI.write("Description: ")
	CLI.write(cmd.description)
	CLI.newline()
	
	if(cmd.arguments.empty()):
		CLI.write("No required arguments.")
	else:
		CLI.write("Arguments: ")
		for arg in cmd.arguments:
			CLI.write(arg.describe())
	
	CLI.newline()


#func get_name():
#	CLI.write("What is your first name?")
#	var first = yield(CLI.input(), "user_input")
#	CLI.write("What is your last name?")
#	var last = yield(CLI.input(), "user_input")
#	CLI.write("Your name is " + first + " " + last)
