class_name ScriptBase extends Node

var game:Game
var script_name:String
var script_origin:String

func debug_print(what:Variant, include_origin:bool = false) -> void:
	var to_print:Variant = what if not include_origin else '%s: %s' % [script_origin, what]
	print(to_print)
	
func call_func(fname:String, args:Array[Variant]) -> void:
	if (has_method(fname)): callv(fname, args)
