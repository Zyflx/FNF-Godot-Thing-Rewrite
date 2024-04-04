class_name Strumline extends Node2D

const Receptor_Node = preload('res://game/objects/note/Receptor.tscn')

var receptors:Array[Receptor] = []
var note_group:Array[Note] = []
@export var is_player:bool = false

func _ready() -> void:
	for i in 4:
		var receptor:Receptor = Receptor_Node.instantiate()
		receptor.lane = i
		receptor.is_player = is_player
		receptors.append(receptor)
		add_child(receptor)
	
func add_note(note:Note) -> void:
	note_group.append(note)
	# note_group.sort_custom(func(a:Note, b:Note): return a.time < b.time)

func delete_note(note:Note) -> void:
	note_group.remove_at(note_group.find(note))
	note.queue_free()

# animation shortcut
func play_anim(index:int, anim:String) -> void:
	receptors[index % 4].play_anim(anim)
	if (anim.contains('confirm') and not is_player):
		receptors[index % 4].reset_time = Conductor.step_crochet * .001

# other shortcuts
func get_receptor_pos(index:int) -> Array[float]:
	return [receptors[index % 4].position.x, receptors[index % 4].position.y]

func to_dir(index:int) -> String:
	return receptors[index % 4].dir_to_name()
