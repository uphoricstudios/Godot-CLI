extends Reference


func _init() -> void:
	CLI.add_command('reload', funcref(self, 'reload'))\
	.set_description("Reloads all commands, and reloads most of the CLIs state.")


func reload() -> void:
	CLI.reload_commands()
	CLI.clear()
	CLI.write("CLI successfully reloaded.")
