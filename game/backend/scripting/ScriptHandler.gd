class_name ScriptHandler extends Node

# internal array for storing scripts
static var scripts_arr:Array[ScriptBase] = []

static func init_scripts(song:String = '') -> void:
	var song_name:String = song.replace(' ', '-').to_lower()
	var path:String = 'res://assets/songs/%s/scripts' % song_name
	var scripts:PackedStringArray = DirAccess.get_files_at(path) if DirAccess.dir_exists_absolute(path) else []
	var script_name:String
	var script_origin:String
	path += '/'
	for script in scripts:
		if (script.get_extension() == 'gd'):
			var scr:GDScript = GDScript.new()
			scr.source_code = FileAccess.get_file_as_string(path + script)
			scr.reload()
			scripts_arr.append(scr.new())
			script_name = script
			script_origin = path + script
			
	for script in scripts_arr:
		script.script_name = script_name
		script.script_origin = script_origin
			
static func call_scripts(fname:String, args:Array[Variant]) -> void:
	if (scripts_arr.size() != 0):
		for script in scripts_arr:
			script.call_func(fname, args)
	
static func free_scripts() -> void:
	if (scripts_arr.size() != 0):
		for script in scripts_arr: script.queue_free()
		scripts_arr.clear()
