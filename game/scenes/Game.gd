extends Node2D

@onready var cam_hud:CanvasLayer = CanvasLayer.new()
@onready var cam_notes:CanvasLayer = CanvasLayer.new()

const Receptor_Node = preload('res://game/objects/note/Receptor.tscn')
const Note_Node = preload('res://game/objects/note/Note.tscn')

var song_data
var note_data
var notes:Array[Note] = []

var plr_strums:Array[Receptor] = []
var cpu_strums:Array[Receptor] = []

var song_speed:float = 0.0

var actions_arr:Array[String] = ['note_left', 'note_down', 'note_up', 'note_right']

var index:int = 0

func _ready() -> void:
	Chart.chart = Chart.load_chart('partner')
	song_data = Chart.chart
	
	Conductor.bpm = song_data.info.bpm
	Conductor.init_music(song_data.info.song, song_data.info.needs_voices)
	Conductor.play_music()
	
	song_speed = song_data.info.speed
	note_data = song_data.notes
	
	cam_hud.layer = -1
	cam_notes.layer = -2
	add_child(cam_hud)
	add_child(cam_notes)
	
	for i in 8:
		var receptor:Receptor = Receptor_Node.instantiate()
		receptor.lane = i % 4
		receptor.is_player = i > 3
		if (i > 3): plr_strums.append(receptor)
		else: cpu_strums.append(receptor)
		cam_notes.add_child(receptor)

func _process(delta:float) -> void:
	while (note_data != null and note_data.size() != 0 and index != note_data.size() and note_data[index].time - Conductor.time < 1800 / song_speed):
		if (note_data[index].time - Conductor.time > 1800 / song_speed): break
		
		var data = note_data[index]
		var note:Note = Note_Node.instantiate()
		note.lane = data.lane % 4
		note.time = data.time
		note.length = data.length
		note.is_sustain = data.is_sustain
		note.must_hit = data.must_hit
		note.speed = song_speed
		notes.append(note)
		cam_notes.add_child(note)
		
		index += 1
		
	if (notes.size() != 0):
		for note in notes:
			var receptor:Receptor = plr_strums[note.lane] if note.must_hit else cpu_strums[note.lane]
			
			note.position.x = receptor.position.x
			note.position.y = receptor.position.y + (Conductor.time - note.time) * (.45 * song_speed)
			
			if (note.was_good_hit):
				cpu_hit(note)
			
			if (note.can_cause_miss):
				destroy_note(note)
				
func step_hit(step:int) -> void:
	pass
	
func beat_hit(beat:int) -> void:
	pass
	
func bar_hit(bar:int) -> void:
	pass
	
func _unhandled_key_input(event) -> void:
	for i in 4:
		if (event.is_action_pressed(actions_arr[i])):
			key_pressed(i)
		if (event.is_action_released(actions_arr[i])):
			key_released(i)
		
func key_pressed(key:int) -> void:
	var hittable_notes:Array[Note] = notes.filter(func(n:Note):
		return n.must_hit and n.can_hit and n.lane == key and not n.was_good_hit and not n.can_cause_miss
	)
	
	hittable_notes.sort_custom(func(a:Note, b:Note): return a.time < b.time)

	if (hittable_notes.size() > 0):
		var note:Note = hittable_notes[0]
			
		if (hittable_notes.size() > 1):
			var behind_note:Note = hittable_notes[1]
				
			if (absf(behind_note.time - note.time) < 2.0):
				destroy_note(behind_note)
			elif (behind_note.lane == note.lane and behind_note.time < note.time):
				note = behind_note
					
		player_hit(note)
	else:
		plr_strums[key].play_anim(plr_strums[key].dir_to_name() + ' press')
	
func key_released(key:int) -> void:
	plr_strums[key].play_anim('static')
	
func player_hit(note:Note) -> void:
	plr_strums[note.lane].play_anim(plr_strums[note.lane].dir_to_name() + ' confirm')
	destroy_note(note)
				
func cpu_hit(note:Note) -> void:
	cpu_strums[note.lane].play_anim(cpu_strums[note.lane].dir_to_name() + ' confirm')
	cpu_strums[note.lane].reset_time = Conductor.step_crochet * .001
	destroy_note(note)
				
func destroy_note(note:Note) -> void:
	notes.remove_at(notes.find(note))
	note.queue_free()
