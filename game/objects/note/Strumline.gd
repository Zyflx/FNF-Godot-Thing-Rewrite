class_name Strumline extends Node2D

const Receptor_Node = preload('res://game/objects/note/Receptor.tscn')
const NoteSplash_Node = preload('res://game/objects/note/NoteSplash.tscn')

var receptors:Array[Receptor] = []
var note_group:Array[Note] = []
@export var is_player:bool = false

@onready var game:Node2D = get_tree().current_scene

func _ready() -> void:
	for i in 4:
		var receptor:Receptor = Receptor_Node.instantiate()
		receptor.lane = i
		receptor.is_player = is_player
		receptors.append(receptor)
		add_child(receptor)
		
func _process(_delta:float) -> void:
	if (note_group.size() != 0):
		for note in note_group:
			note.follow_strumline(self)
				
			if (note.was_good_hit): game.cpu_hit(note)
			if (note.can_cause_miss): game.note_miss(note)
				
			if (note.data.is_sustain):
				if (not note.data.must_hit):
					if (note.self_modulate.a == 0):
						if (note.data.time < note.sustain_kill_threshold):
							game.destroy_note(self, note)
				else: if (note.is_holding): game.sustain_hit(note)
	
func add_note(note:Note) -> void:
	note_group.append(note)
	add_child(note)
	# note_group.sort_custom(func(a:Note, b:Note): return a.time < b.time)

func delete_note(note:Note) -> void:
	note_group.remove_at(note_group.find(note))
	note.queue_free()
	
# splashes
func spawn_splash(note:Note) -> void:
	var splash:NoteSplash = NoteSplash_Node.instantiate()
	splash.spawn_splash(note)
	splash.position = get_receptor_pos(note.data.lane)
	add_child(splash)

# animation shortcut
func play_anim(index:int, anim:String) -> void:
	receptors[index % 4].play_anim(anim)
	if (anim.contains('confirm') and not is_player):
		receptors[index % 4].reset_time = Conductor.step_crochet * .001

# other shortcuts
func get_receptor_pos(index:int) -> Vector2:
	return receptors[index % 4].position
	
func get_default_receptor_pos(index:int) -> Vector2:
	return receptors[index % 4].init_pos

func to_dir(index:int) -> String:
	return receptors[index % 4].dir_to_name()
