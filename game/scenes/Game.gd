extends Node2D

const Note_Node = preload('res://game/objects/note/Note.tscn')

# ui
@onready var cam_hud:CanvasLayer = $CamHUD
@onready var cam_notes:CanvasLayer = $CamNotes
@onready var game_ui:GameUI = $CamHUD/GameUI

# song stuff
var song_data
var song_speed:float = 0.0

# note stuff
var note_data
var cur_note:int = 0
@onready var plr_strumline:Strumline = $CamNotes/PlayerStrumline
@onready var cpu_strumline:Strumline = $CamNotes/CPUStrumline

# judgement stuff
enum JudgementData {UNDEFINED = 0, TIER1 = 1, TIER2 = 2, TIER3 = 3, TIER4 = 4}
var judgement_data:Dictionary = {
	# format: judgement name, timing window, accuracy modifier, score, health gain
	JudgementData.TIER4: ['sick', 45, 1, 350, .023],
	JudgementData.TIER3: ['good', 90, .75, 200, .023],
	JudgementData.TIER2: ['bad', 135, .4, 100, .015],
	JudgementData.TIER1: ['shit', 166, .15, 50, .01],
	JudgementData.UNDEFINED: ['undefined', 0, 0, 0, 0]
}

# controls
var actions_arr:Array[String] = ['note_left', 'note_down', 'note_up', 'note_right']

# stats
var score:int = 0
var misses:int = 0
var combo:int = 0
var health:float = 2.0

func _ready() -> void:
	Chart.chart = Chart.load_chart('partner')
	song_data = Chart.chart
	
	Conductor.bpm = song_data.info.bpm
	Conductor.init_music(song_data.info.song, song_data.info.needs_voices)
	Conductor.play_music()
	
	song_speed = song_data.info.speed
	note_data = song_data.notes.duplicate()

func _process(_delta:float) -> void:
	while (note_data != null and note_data.size() != 0 and cur_note != note_data.size() and note_data[cur_note].time - Conductor.time < 1800 / song_speed):
		if (note_data[cur_note].time - Conductor.time > 1800 / song_speed): break
		
		var data = note_data[cur_note]
		var strumline:Strumline = plr_strumline if data.must_hit else cpu_strumline
		
		var note:Note = Note_Node.instantiate()
		note.append_data(data)
		note.speed = song_speed
		
		strumline.add_note(note)
		cam_notes.add_child(note)
		
		cur_note += 1
	
	for strumline in [plr_strumline, cpu_strumline]:
		if (strumline.note_group.size() != 0):
			for note in strumline.note_group:
				note.follow_strumline(strumline)
				
				if (note.was_good_hit): cpu_hit(note)
				if (note.can_cause_miss): note_miss(note)
				
				if (note.data.is_sustain):
					if (not note.data.must_hit):
						if (note.self_modulate.a == 0):
							# my fucking dumbass was using length instead of the sustain size
							# now this works properly
							if (note.data.time < note.sustain_kill_threshold):
								destroy_note(cpu_strumline, note)
					else: if (note.is_holding): sustain_hit(note)
				
func step_hit(step:int) -> void:
	pass
	
func beat_hit(beat:int) -> void:
	pass
	
func bar_hit(bar:int) -> void:
	pass
	
func _unhandled_key_input(event:InputEvent) -> void:
	# took a page out of idk rhythm for inputs lol
	for i in 4:
		if (event.is_action_pressed(actions_arr[i])):
			key_pressed(i)
		if (event.is_action_released(actions_arr[i])):
			key_released(i)
		
func key_pressed(key:int) -> void:
	var hittable_notes:Array[Note] = plr_strumline.note_group.filter(func(n:Note):
		return n.data.must_hit and n.can_hit and n.data.lane == key and not n.was_good_hit and not n.can_cause_miss
	)
	
	hittable_notes.sort_custom(func(a:Note, b:Note): return a.data.time < b.data.time)

	if (hittable_notes.size() > 0):
		var note:Note = hittable_notes[0]
			
		if (hittable_notes.size() > 1):
			var behind_note:Note = hittable_notes[1]
				
			if (absf(behind_note.data.time - note.data.time) < 2.0):
				destroy_note(plr_strumline, behind_note)
			elif (behind_note.data.lane == note.data.lane and behind_note.data.time < note.data.time):
				note = behind_note
					
		player_hit(note)
	else:
		plr_strumline.play_anim(key, plr_strumline.to_dir(key) + ' press')
	
func key_released(key:int) -> void:
	plr_strumline.play_anim(key, 'static')
	
func player_hit(note:Note) -> void:
	plr_strumline.play_anim(note.data.lane, plr_strumline.to_dir(note.data.lane) + ' confirm')
	
	var judgement:int = get_judgement(absf(note.data.time - Conductor.time))
	
	combo += 1
	health += judgement_data[judgement][4]
	score += judgement_data[judgement][3]
	
	game_ui.update_accuracy(judgement)
	
	judge_popup(judgement)
	
	if (note.data.is_sustain):
		note.self_modulate.a = 0
		note.is_holding = true
	else: destroy_note(plr_strumline, note)
				
func cpu_hit(note:Note) -> void:
	cpu_strumline.play_anim(note.data.lane, cpu_strumline.to_dir(note.data.lane) + ' confirm')
	if (not note.data.is_sustain): destroy_note(cpu_strumline, note)
	else: note.self_modulate.a = 0
	
# for player sustains
func sustain_hit(note:Note) -> void:
	plr_strumline.play_anim(note.data.lane, plr_strumline.to_dir(note.data.lane) + ' confirm')
	if (Input.is_action_just_released(actions_arr[note.data.lane]) and note.data.time > note.sustain_kill_threshold - 1):
		note.is_holding = false
		note_miss(note)
	if (note.data.time < note.sustain_kill_threshold):
		note.is_holding = false
		destroy_note(plr_strumline, note)
	
func note_miss(note:Note) -> void:
	misses += 1
	game_ui.update_accuracy(JudgementData.UNDEFINED, true)
	destroy_note(plr_strumline, note)
				
func destroy_note(strumline:Strumline, note:Note) -> void:
	strumline.delete_note(note)
	
func judge_popup(judgement:int = 1) -> void:
	var spr:FunkSprite = FunkSprite.new()
	spr.scale = Vector2(.7, .7)
	spr.texture = load('res://assets/images/ui/' + judgement_data[judgement][0] + '.png')
	spr.active = true
	spr.acceleration.y = 550
	spr.velocity.x = -randi_range(0, 10)
	spr.velocity.y = -randi_range(140, 175)
	spr.position = Vector2(get_viewport().size.x * .5, get_viewport().size.y * .5)
	add_child(spr)
	
	var twn:Tween = create_tween()
	twn.tween_property(spr, 'modulate', Color.TRANSPARENT, .2).set_delay(Conductor.crochet * .001)
	twn.finished.connect(spr.queue_free)
	
func get_judgement(diff:float = -1) -> JudgementData:
	for i in judgement_data.keys():
		if (diff <= judgement_data[i][1]):
			return i
	return JudgementData.UNDEFINED
