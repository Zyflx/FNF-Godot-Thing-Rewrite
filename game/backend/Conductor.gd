extends Node

signal step_hit(step:int)
signal beat_hit(beat:int)
signal bar_hit(bar:int)
signal song_ended()

var active:bool = true

var time:float = 0.0;

var bpm:float = 100.0:
	set(new_bpm):
		bpm = new_bpm
		crochet = (60.0 / new_bpm) * 1000.0
		step_crochet = crochet * .25
var crochet:float = (60.0 / bpm) * 1000.0
var step_crochet:float = crochet * .25

var beat:int = 0
var step:int = 0
var bar:int = 0

var _beat_t:float = 0.0
var _step_t:float = 0.0

var inst:AudioStreamPlayer
var voices:AudioStreamPlayer

func _process(delta:float) -> void:
	if (not active): return
	
	time += delta * 1000.0

	if (time >= 0):
		sync_music()
		
		if (time > (_beat_t + crochet)):
			_beat_t += crochet
			beat += 1
			beat_hit.emit(beat)
			if (beat % 4 == 0):
				bar += 1
				bar_hit.emit(bar)
		if (time > (_step_t + step_crochet)):
			_step_t += step_crochet
			step += 1
			step_hit.emit(step)
			
		if (time >= inst.stream.get_length() * 1000.0):
			song_ended.emit()
			
func init(song:String, needs_voices:bool, funcs:Array[Callable]):
	reset()
	init_music(song, needs_voices)
	init_signals(funcs)
			
func init_signals(funcs:Array[Callable]) -> void:
	step_hit.connect(funcs[0])
	beat_hit.connect(funcs[1])
	bar_hit.connect(funcs[2])
	song_ended.connect(funcs[3])
	
func init_music(song:String, needs_voices:bool) -> void:
	inst = get_tree().current_scene.get_node('Inst')
	inst.stream = load('res://assets/songs/' + song.replace(' ', '-').to_lower() + '/audio/Inst.ogg')
	voices = get_tree().current_scene.get_node('Voices')
	if (needs_voices):
		voices.stream = load('res://assets/songs/' + song.replace(' ', '-').to_lower() + '/audio/Voices.ogg')
	
func play_music() -> void:
	active = true
	inst.play()
	if (voices.stream != null): voices.play()
	
func stop_music() -> void:
	reset()
	inst.stop()
	if (voices.stream != null): voices.stop()
	
func sync_music() -> void:
	sync_stream(inst)
	sync_stream(voices)
	
func sync_stream(stream:AudioStreamPlayer) -> void:
	if (stream == null or not stream.is_playing()): return
	var stream_time:float = stream.get_playback_position() * 1000.0
	if (absf(time - stream_time) > 20.0): stream.seek(time * .001)
	
func reset() -> void:
	beat = 0; _beat_t = 0;
	step = 0; _step_t = 0;
	bar = 0; time = 0;
