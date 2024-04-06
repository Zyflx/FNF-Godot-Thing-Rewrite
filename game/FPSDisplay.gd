extends CanvasLayer

@onready var fps_txt:Label = Label.new()
var _delta_timeout:float = .0;

func _ready() -> void:
	layer = 2
	fps_txt.position = Vector2(10, 10)
	add_child(fps_txt)

func _process(delta:float) -> void:
	_delta_timeout += delta
	
	if _delta_timeout >= .5:
		_delta_timeout = .0
		return
		
	var fps:float = Engine.get_frames_per_second()
	var scene:String = 'None' if get_tree().current_scene == null else get_tree().current_scene.name + ' Scene'
	var txt:String = '%s FPS\n%s / %s\n' + scene
	fps_txt.text = txt % [fps, String.humanize_size(OS.get_static_memory_usage()), String.humanize_size(OS.get_static_memory_peak_usage())]
	
