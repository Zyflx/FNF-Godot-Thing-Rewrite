extends CanvasLayer

@onready var fps_txt:Label = Label.new()
var _delta_timeout:float = .0;
var volume:float = 1.0:
	set(vol):
		volume = vol
		AudioServer.set_bus_volume_db(0, linear_to_db(volume))

func _ready() -> void:
	layer = 2
	fps_txt.position = Vector2(10, 10)
	fps_txt.add_theme_font_override('font', load('res://assets/fonts/JetBrainsMono-Bold.ttf'))
	fps_txt.add_theme_color_override('font_outline_color', Color('000000'))
	fps_txt.add_theme_constant_override('outline_size', 12)
	add_child(fps_txt)

func _process(delta:float) -> void:
	_delta_timeout += delta
	
	if _delta_timeout >= .5:
		_delta_timeout = .0
		return
		
	var fps:float = Engine.get_frames_per_second()
	var scene:String = 'None' if get_tree().current_scene == null else get_tree().current_scene.name + ' Scene'
	if (OS.is_debug_build()):
		var mem:int = OS.get_static_memory_usage()
		var peak_mem:int = OS.get_static_memory_peak_usage()
		var txt:String = '%s FPS\n%s / %s\n%s' % [fps, String.humanize_size(mem), String.humanize_size(peak_mem), scene]
		fps_txt.text = txt
	else: fps_txt.text = '%s FPS\n%s' % [fps, scene]
	
# totally didn't use idk rhythms volume implementation
func _unhandled_input(event:InputEvent) -> void:
	var actions:Array[String] = ['volume_up', 'volume_down']
	for i in 2:
		if (event.is_action_pressed(actions[i])):
			match i:
				0: volume = min(volume + .05, 1)
				1: volume = max(volume - .05, 0)
