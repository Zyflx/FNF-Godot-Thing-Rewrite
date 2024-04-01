extends Label

var _delta_timeout:float = .0;

func _ready() -> void:
	position = Vector2(10, 10)

func _process(delta:float) -> void:
	_delta_timeout += delta
	
	if _delta_timeout >= .5:
		_delta_timeout = .0
		return
		
	var fps:float = Engine.get_frames_per_second()
	var scene:String = 'None' if get_tree().current_scene == null else get_tree().current_scene.name + ' Scene'
	var txt:String = '%s FPS\n%s / %s\n' + scene
	text = txt % [fps, String.humanize_size(OS.get_static_memory_usage()), String.humanize_size(OS.get_static_memory_peak_usage())]
	
