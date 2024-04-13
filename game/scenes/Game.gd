class_name Game extends Node2D

const Note_Node = preload('res://game/objects/note/Note.tscn')
const JudgeSprite_Node = preload('res://game/objects/JudgeSprite.tscn')
const ComboNumber_Node = preload('res://game/objects/ComboNumber.tscn')

# ui
@onready var cam_game:Camera2D = $CamGame
@onready var game_ui:GameUI = $UI/GameUI
var default_zoom:float = .8

# song stuff
var song_data:Chart
var song_speed:float = 0.0
var started_song:bool = false

# countdown
@onready var countdown_tmr:Timer = Timer.new()
var countdown_loops:int = 0
var countdown_sprs:Array[String] = ['ready', 'set', 'go']
var countdown_sounds:Array[String] = ['intro3', 'intro2', 'intro1', 'introGo']

# note stuff
var note_data:Array[NoteData]
var cur_note:int = 0
@onready var plr_strumline:Strumline = $UI/GameUI/PlayerStrumline
@onready var cpu_strumline:Strumline = $UI/GameUI/CPUStrumline

# characters
@onready var bf:Character = $Boyfriend
@onready var opponent:Character = $Opponent
@onready var spectator:Character = $Spectator

# controls
var actions_arr:Array[String] = ['note_left', 'note_down', 'note_up', 'note_right']

# stats
var score:int = 0
var misses:int = 0
var combo:int = 0
var health:float = 50.0:
	set(v): health = clampf(v, 0, 100.0)

static var instance:Game

func _ready() -> void:
	instance = self
	
	Timings.reset()
	
	song_data = Chart.chart

	Conductor.bpm = song_data.info.bpm
	Conductor.init(song_data.info.song, song_data.info.needs_voices, [step_hit, beat_hit, bar_hit, song_ended])
	
	song_speed = song_data.info.speed
	note_data = song_data.notes.duplicate()
	
	ScriptHandler.init_scripts(song_data.info.song)
	for script in ScriptHandler.scripts_arr: script.game = self
	
	bf.position = Vector2(200, 350)
	opponent.position = Vector2(-100, 350)
	spectator.position.x -= 300
	
	move_camera(song_data.section_data[0].mustHitSection)
	
	add_child(countdown_tmr)
	init_countdown()
	
	ScriptHandler.call_scripts('on_ready', [])

func _process(delta:float) -> void:
	ScriptHandler.call_scripts('on_process', [delta])
	
	if (Input.is_action_just_pressed('reset_state')):
		Conductor.stop_music()
		get_tree().reload_current_scene()
		
	if (Input.is_action_just_pressed('back_to_menu')):
		song_ended()
		
	if (Conductor.time >= 0 and not started_song):
		started_song = true
		Conductor.play_music()
	
	cam_game.zoom = Vector2(lerpf(default_zoom, cam_game.zoom.x, exp(-delta * 6)), lerpf(default_zoom, cam_game.zoom.y, exp(-delta * 6)))
	game_ui.scale = Vector2(lerpf(1, game_ui.scale.x, exp(-delta * 6)), lerpf(1, game_ui.scale.y, exp(-delta * 6)))
	
	while (note_data != null and note_data.size() != 0 and cur_note != note_data.size() and note_data[cur_note].time - Conductor.time < 1800 / song_speed):
		if (note_data[cur_note].time - Conductor.time > 1800 / song_speed): break
		
		var data:NoteData = note_data[cur_note]
		var strumline:Strumline = plr_strumline if data.must_hit else cpu_strumline
		
		var note:Note = Note_Node.instantiate()
		note.append_data(data)
		note.speed = song_speed
		
		strumline.add_note(note)
		
		ScriptHandler.call_scripts('on_note_spawn', [note])
		
		cur_note += 1
		
	ScriptHandler.call_scripts('on_process_post', [delta])
	
func step_hit(step:int) -> void:
	ScriptHandler.call_scripts('step_hit', [step])
	
func beat_hit(beat:int) -> void:
	# print('beat hit %s' % beat)
	game_ui.icon_bump()
	if (beat % 2 == 0):
		if (not bf.animation.contains('sing')): bf.dance()
		if (not opponent.animation.contains('sing')): opponent.dance()
	spectator.dance()
	ScriptHandler.call_scripts('beat_hit', [beat])
	
func bar_hit(bar:int) -> void:
	cam_game.zoom.x += .03
	cam_game.zoom.y += .03
	
	game_ui.scale.x += .03
	game_ui.scale.y += .03

	if (song_data.section_data[bar] != null):
		move_camera(song_data.section_data[bar].mustHitSection)
		var has_change:bool = song_data.section_data[bar].has('changeBPM') and song_data.section_data[bar].changeBPM
		if (has_change and Conductor.bpm != song_data.section_data[bar].bpm):
			Conductor.bpm = song_data.section_data[bar].bpm
			
	ScriptHandler.call_scripts('bar_hit', [bar])
	
func init_countdown() -> void:
	if (countdown_loops == 0):
		Conductor.time = -Conductor.crochet * 5.0
		Conductor.active = true
	
	countdown_tmr.start(Conductor.crochet * .001)
	
	await countdown_tmr.timeout
	
	if (countdown_loops < 4):
		if (countdown_loops >= 1):
			var count_spr:Sprite2D = Sprite2D.new()
			count_spr.texture = load('res://assets/images/ui/countdown/%s.png' % countdown_sprs[countdown_loops - 1])
			count_spr.position = Vector2(get_viewport().size.x * .5, get_viewport().size.y * .5)
			game_ui.add_child(count_spr)
						
			var count_spr_twn:PropertyTweener = create_tween().tween_property(count_spr, 'modulate:a', 0, Conductor.crochet * .001)
			count_spr_twn.set_trans(Tween.TRANS_CUBIC)
			count_spr_twn.finished.connect(count_spr.queue_free)
			
			bf.dance()
			opponent.dance()
			spectator.dance()
			
		var sound:AudioStreamPlayer = AudioStreamPlayer.new()
		sound.stream = load('res://assets/sounds/%s.ogg' % countdown_sounds[countdown_loops])
		add_child(sound)
		sound.play()
		sound.finished.connect(sound.queue_free)
		
	countdown_loops += 1
	init_countdown()

func song_ended() -> void:
	Conductor.stop_music()
	ScriptHandler.free_scripts()
	get_tree().change_scene_to_file('res://game/scenes/SongSelect.tscn')
	
func move_camera(must_hit:bool) -> void:
	var who:Character = bf if must_hit else opponent
	cam_game.position = who.get_cam_pos()
	ScriptHandler.call_scripts('on_move_camera', ['bf' if must_hit else 'opponent'])
	
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
	
	bf.sing(note.data.lane)
	
	var judgement:int = Timings.get_judgement(absf(note.data.time - Conductor.time))
	var judge_name:String = Timings.judgement_data[judgement][0]
	
	if (judge_name == 'sick' or judge_name == 'swag'):
		plr_strumline.spawn_splash(note)
	
	combo += 1
	health += Timings.judgement_data[judgement][4] * 50.0
	score += Timings.judgement_data[judgement][3]
	
	Timings.update_accuracy(judgement)
	
	judge_popup(judgement)
	
	ScriptHandler.call_scripts('player_hit', [note])
	
	if (note.data.is_sustain):
		note.self_modulate.a = 0
		note.is_holding = true
	else: destroy_note(plr_strumline, note)
				
func cpu_hit(note:Note) -> void:
	cpu_strumline.play_anim(note.data.lane, cpu_strumline.to_dir(note.data.lane) + ' confirm')
	opponent.sing(note.data.lane)
	ScriptHandler.call_scripts('cpu_hit', [note])
	if (not note.data.is_sustain): destroy_note(cpu_strumline, note)
	else: note.self_modulate.a = 0
	
# for player sustains
func sustain_hit(note:Note) -> void:
	if (Input.is_action_just_released(actions_arr[note.data.lane])):
		note.is_holding = false
		note_miss(note)
		return
	if (note.data.time < note.sustain_kill_threshold):
		note.is_holding = false
		destroy_note(plr_strumline, note)
	plr_strumline.play_anim(note.data.lane, plr_strumline.to_dir(note.data.lane) + ' confirm')
	bf.sing(note.data.lane)
	
func note_miss(note:Note) -> void:
	misses += 1
	combo = 0
	health -= (.0475 * 50.0)
	Timings.update_accuracy(Timings.JudgementData.UNDEFINED, true)
	bf.sing(note.data.lane, true)
	ScriptHandler.call_scripts('note_miss', [note])
	destroy_note(plr_strumline, note)
				
func destroy_note(strumline:Strumline, note:Note) -> void:
	strumline.delete_note(note)
	
func judge_popup(judgement:int = 1) -> void:
	var spr:JudgeSprite = JudgeSprite_Node.instantiate()
	spr.spawn(judgement)
	spr.position = Vector2(get_viewport().size.x * .5, get_viewport().size.y * .5)
	game_ui.add_child(spr)
	
	var twn:Tween = create_tween()
	twn.tween_property(spr, 'modulate:a', 0, .2).set_delay(Conductor.crochet * .001)
	twn.finished.connect(spr.queue_free)
	
	var sep_score:Array[int] = []
	if (combo >= 1000): sep_score.append(floori(combo * .001) % 10)
	sep_score.append(floori(combo * .01) % 10)
	sep_score.append(floori(combo * .1) % 10)
	sep_score.append(combo % 10)
	
	var loop:int = 0
	
	for i in sep_score:
		var num:ComboNumber = ComboNumber_Node.instantiate()
		num.spawn(i)
		num.position.x = spr.position.x - 150 + (43 * loop)
		num.position.y = spr.position.y + 95
		game_ui.add_child(num)
		
		var ntwn:Tween = create_tween()
		ntwn.tween_property(num, 'modulate:a', 0, .2).set_delay(Conductor.crochet * .002)
		ntwn.finished.connect(num.queue_free)
		
		loop += 1
