extends Node

var time:float = 0.0;

var bpm:float = 100.0:
	set(new_bpm):
		bpm = new_bpm
		crochet = (60.0 / bpm) * 1000.0
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
	time += delta * 1000.0

	if (time >= 0):
		sync_music()
		
		if (time > (_beat_t + crochet)):
			_beat_t += crochet
			beat += 1
			if (get_tree().current_scene.has_method('beat_hit')):
				get_tree().current_scene.callv('beat_hit', [beat])
			if (beat % 4 == 0):
				bar += 1
				if (get_tree().current_scene.has_method('bar_hit')):
					get_tree().current_scene.callv('bar_hit', [bar])
		if (time > (_step_t + step)):
			_step_t += step_crochet
			step += 1
			if (get_tree().current_scene.has_method('step_hit')):
				get_tree().current_scene.callv('step_hit', [step])
	
func init_music(song:String, needs_voices:bool) -> void:
	inst = get_tree().current_scene.get_node('Inst')
	inst.stream = load('res://assets/songs/' + song.replace(' ', '-').to_lower() + '/audio/Inst.ogg')
	voices = get_tree().current_scene.get_node('Voices')
	if (needs_voices):
		voices.stream = load('res://assets/songs/' + song.replace(' ', '-').to_lower() + '/audio/Voices.ogg')
	
func play_music() -> void:
	inst.play()
	if (voices.stream != null): voices.play()
	
func sync_music() -> void:
	sync_stream(inst)
	sync_stream(voices)
	
func sync_stream(stream:AudioStreamPlayer) -> void:
	if (stream == null or not stream.is_playing()): return
	var stream_time:float = stream.get_playback_position() * 1000.0
	if (absf(time - stream_time) > 20.0): stream.seek(time * .001)