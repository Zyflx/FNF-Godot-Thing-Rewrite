extends Node

var options:ConfigFile

func _ready() -> void:
	options = ConfigFile.new()
	options.load('res://options.cfg')
	
func set_option(option:String, value:Variant) -> void:
	options.set_value('Prefs', option, value)
	save()
	
func get_option(option:String) -> Variant:
	return options.get_value('Prefs', option)
	
func set_bind(action_name:String, bind:String) -> void:
	options.set_value('Keybinds', action_name, bind)
	save()
	
func get_bind(action_name:String) -> String:
	return options.get_value('Keybinds', action_name)
	
func save() -> void:
	options.save('res://options.cfg')
