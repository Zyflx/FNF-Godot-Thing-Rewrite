class_name NoteData extends Resource

var time:float
var lane:int
var length:float
var is_sustain:bool
var must_hit:bool
	
func _init(_time:float, _lane:int, _length:float, _is_sustain:bool, _must_hit:bool) -> void:
	time = _time
	lane = _lane
	length = _length
	is_sustain = _is_sustain
	must_hit = _must_hit
