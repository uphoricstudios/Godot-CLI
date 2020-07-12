extends Reference


const BB = preload("res://addons/uphoric.CLI/src/helpers/BB.gd")
const CONFIG_PATH: String = "res://addons/uphoric.CLI/plugin.cfg"

var PLATFORM: String = OS.get_name()

func _init() -> void:
	var terminal_name: String
	
	if(PLATFORM == "Windows"):
		terminal_name = "powershell"
	
	elif(PLATFORM == "X11"):
		pass

	elif(PLATFORM == "OSX"):
		pass
	
	CLI.add_command('clear', funcref(self, 'clear'))\
	.set_description("Clears the console.")
	
	CLI.add_command('ls', funcref(self, 'ls'))\
	.set_description("Lists the current directory's contents.")\
	.add_argument("path", TYPE_STRING, "Path to directory.", true)
	
	CLI.add_command('cd', funcref(self, 'cd'))\
	.set_description("Changes the current working directory.")\
	.add_argument("path", TYPE_STRING, "Path to directory.")
	
	CLI.add_command('opendir', funcref(self, 'opendir'))\
	.set_description("Opens PLATFORMs file explorer to current working directory.")\
	.add_argument("path", TYPE_STRING, "Path to directory.", true)
	
	CLI.add_command('mkdir', funcref(self, 'mkdir'))\
	.set_description("Creates directory at a given path.")\
	.add_argument("path", TYPE_STRING, "Path to directory.")
	
	CLI.add_command('cwd', funcref(self, 'cwd'))\
	.set_description("Shows current working directory.")
	
	CLI.add_command('backup', funcref(self, 'backup'))\
	.set_description("Backs up current Godot project to a compressed file. The file name will be the date and time of backup.")\
	
	CLI.add_command(terminal_name, funcref(self, 'native_terminal'))\
	.set_description("Sends commands to the platforms native terminal. All commands will be non-blocking and will not return an output. The use of this command is discouraged, it's only meant for things that cannot be done with the CLI.")\
	.add_argument("args", TYPE_STRING, "Arguments to be passed to the terminal.")
	
	CLI.add_command('commands', funcref(self, 'commands'))\
	.set_description("Lists all available commands.")
	
	CLI.add_command('help', funcref(self, 'help'))\
	.set_description("Shows command's description and arguments.")\
	.add_argument("command", TYPE_STRING, "Name of command to get help for.")
	
	CLI.add_command('about', funcref(self, 'about'))\
	.set_description("Shows CLIs about.")
	


func clear() -> void:
	CLI.clear()


# add config to allow to show hidden
func ls(path: String = "") -> void:
	var dir: Directory = Directory.new()
	var file := File.new()
	var current_dir: String = CLI.get_current_directory() + path
	
	if(!path.empty()):
		if(!dir.dir_exists(current_dir)):
			CLI.error("Cannot find path to '" + path + "' because it does not exist.")
			return
	
	var hide_hidden_files: bool = true
	var cells: Array = []
	
	cells.append(BB.cell(BB.right(BB.bold("Bytes"))))
	cells.append(BB.cell(""))
	cells.append(BB.cell(BB.bold("Names")))
	cells.append(BB.cell(BB.right("=====")))
	cells.append(BB.cell("|"))
	cells.append(BB.cell("====="))

	if dir.open(current_dir) == OK:
		dir.list_dir_begin(true, hide_hidden_files)
		var current: String = dir.get_next()
		
		while(!current.empty()):
			
			if(dir.file_exists(current)):
				var test = file.open(current_dir + "/" + current, File.READ)
				cells.append(BB.cell((BB.right(str(file.get_len())))))
				cells.append(BB.cell("|"))
				cells.append(BB.cell(current))
				file.close()
			
			else:
				cells.append(BB.cell(""))
				cells.append(BB.cell("|"))
				cells.append(BB.cell(current))
			
			current = dir.get_next()
	
	CLI.newline()
	CLI.write(BB.table(3, cells))
	CLI.newline()


func cd(path: String) -> void:
	if(CLI.change_working_directory(path)):
		CLI.write("Directory: " + CLI.get_current_directory())
		return
	CLI.error("Cannot find path to '" + path + "' because it does not exist.")


func opendir(path: String = "") -> void:
	var dir: Directory = Directory.new()
	var current_dir: String = CLI.get_current_directory() + path
	
	if(!path.empty()):
		if(!dir.dir_exists(current_dir)):
			CLI.error("Cannot find path to '" + path + "' because it does not exist.")
			return
	
	if(PLATFORM == "Windows"):
		current_dir = current_dir.replace("/", "\\")
		OS.execute("explorer", [current_dir], false)
		CLI.write("Opening directory...")
	
	elif(PLATFORM == "X11"):
		pass
	
	elif(PLATFORM == "OSX"):
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
	
	if(PLATFORM == "Windows"):
		OS.execute("powershell.exe", [args], false)
		CLI.write("Backup complete.")
	
	elif(PLATFORM == "X11"):
		pass
	
	elif(PLATFORM == "OSX"):
		pass


func native_terminal(args: String) -> void:
	if(PLATFORM == "Windows"):
		OS.execute("powershell.exe", [args], false)
		pass
	
	elif(PLATFORM == "X11"):
		pass
	
	elif(PLATFORM == "OSX"):
		pass


func commands() -> void:
	var command_list: Dictionary = CLI._command_list.get_commands()
	var cells: Array = []
	
	cells.append(BB.cell(BB.right(BB.bold("Name"))))
	cells.append(BB.cell(""))
	cells.append(BB.cell(BB.bold("Description")))
	cells.append(BB.cell(BB.right("=====")))
	cells.append(BB.cell("|"))
	cells.append(BB.cell("====="))
	
	for key in command_list:
		cells.append(BB.cell(BB.right(BB.color(key, BB.GOLD))))
		cells.append(BB.cell("|"))
		cells.append(BB.cell(command_list[key].description))
	
	CLI.newline()
	CLI.write(BB.table(3, cells))


func help(command: String) -> void:
	var command_list = CLI._command_list
	
	if(!command_list.has(command)):
		CLI.error("The command " + BB.color(command, BB.GOLD) + " does not exist.")
		return
	
	var cmd = command_list.get_command(command)

	CLI.newline()
	CLI.write(BB.color(cmd.name, BB.GOLD) )
	CLI.newline()
	CLI.write(BB.bold("Description") + ": ")
	CLI.write(cmd.description)
	CLI.newline()
	
	if(cmd.arguments.empty()):
		CLI.write("No required arguments.")
	
	else:
		CLI.write(BB.bold("Arguments") + ": ")
		var cells: Array = []
		var arg_name: String = BB.cell("[{name}: {type}]")
		
		for arg in cmd.arguments:
			cells.append(arg_name.format({
				"name": arg.get_name(),
				"type": BB.color(arg.get_type(), BB.L_BLUE)
			}))
			cells.append(BB.cell(" :: "))
			cells.append(BB.cell("optional" if(arg.is_optional()) else "required"))
			cells.append(BB.cell(" :: "))
			cells.append(BB.cell(arg.get_description()))
		CLI.write(BB.table(5, cells))
	
	CLI.newline()


func about() -> void:
	var config: ConfigFile = ConfigFile.new()
	var godot_engine: Dictionary = Engine.get_version_info()
	var cli_version: String = "0.0.0"
	var godot_version: String = "{ma}.{mi}.{pa}"
	
	godot_version = godot_version.format({
		"ma": godot_engine["major"],
		"mi": godot_engine["minor"],
		"pa": godot_engine["patch"]
	})
	
	if(config.load(CONFIG_PATH) == OK):
		cli_version = config.get_value("plugin", "version")
	
	CLI.write(BB.bold("uPhoric Studios"))
	CLI.write("CLI " + cli_version)
	CLI.write("Runnng on Godot Engine " + godot_version)
	CLI.newline()
	CLI.write("Created by: Alexandros Petrou & Mayhew Steyn")


#func get_name():
#	CLI.write("What is your first name?")
#	var first = yield(CLI.input(), "user_input")
#	CLI.write("What is your last name?")
#	var last = yield(CLI.input(), "user_input")
#	CLI.write("Your name is " + first + " " + last)
