class_name Chart extends Resource
		
class JsonData extends Resource:
	var song:String
	var player1:String
	var player2:String
	var stage:String
	var needs_voices:bool
	var bpm:float
	var speed:float
	
	func _init(_song:String, _player1:String, _player2:String, _stage:String, _needs_voices:bool, _bpm:float, _speed:float) -> void:
		song = _song
		player1 = _player1
		player2 = _player2
		stage = _stage
		needs_voices = _needs_voices
		bpm = _bpm
		speed = _speed
		
var info:JsonData = null
var notes:Array[NoteData] = []
var section_data:Array = []
static var chart:Chart

static func load_chart(song:String) -> Chart:
	var path:String = 'res://assets/songs/' + song.replace(' ', '-').to_lower() + '/normal.json'
	if (not FileAccess.file_exists(path)): return
	var json:Variant = JSON.parse_string((FileAccess.open(path, FileAccess.READ).get_as_text())).song
	var c:Chart = Chart.new()
	
	c.section_data = json.notes
	
	c.info = JsonData.new(
		json.song, json.player1, json.player2, 'stage' if json.stage == null else json.stage,
		json.needsVoices, json.bpm, json.speed
	)
	
	for sec in json.notes:
		for note in sec.sectionNotes:
			if (note[1] == -1 or note[2] is String): continue
			var time:float = maxf(0, note[0])
			var lane:int = int(note[1]) % 4
			var length:float = maxf(0, note[2])
			var is_sustain:bool = length > 0.0
			var must_hit:bool = not sec.mustHitSection if note[1] > 3 else sec.mustHitSection
			
			var note_data:NoteData = NoteData.new(time, lane, length, is_sustain, must_hit)
			c.notes.append(note_data)
			
	c.notes.sort_custom(func(a:NoteData, b:NoteData): return a.time < b.time)
	
	return c
