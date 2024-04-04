class_name Note extends AnimatedSprite2D

static var col_arr:Array[String] = ['purple', 'blue', 'green', 'red']
static var dir_arr:Array[String] = ['left', 'down', 'up', 'right']
static var swag_width:float = 160 * .7

var data:NoteData = NoteData.new(0, 0, 0, false, false)
var speed:float = 0.0
# only for player
var is_holding:bool = false:
	set(v): if (data.must_hit): is_holding = v
# adding to the threshold by 1 to give a bit of a delay before the sustain gets killed
# this is so sustains aren't as strict (hopefully)
var sustain_kill_threshold:float = 0:
	get: return (Conductor.time - (sustain.size.y * .5)) + 1 if data.is_sustain else 0

var can_hit:bool = false:
	get: return data.must_hit and data.time >= Conductor.time - (166 * .8) \
	and data.time <= Conductor.time + (166 * 1)
var can_cause_miss:bool = false:
	get: return not is_holding and data.must_hit and position.y > get_viewport().size.y + 30
var was_good_hit:bool = false:
	get: return not data.must_hit and data.time <= Conductor.time

var sustain:TextureRect
var end:Sprite2D

func _ready() -> void:
	scale = Vector2(.7, .7)
	play(col_arr[data.lane % 4])
	if (data.is_sustain):
		sustain = TextureRect.new()
		sustain.texture = load('res://assets/images/note/note_assets/' + col_arr[data.lane % 4] + ' hold piece0000.png')
		sustain.size = Vector2(sustain.texture.get_width(), .54 * speed * data.length)
		sustain.position.x = (sustain.texture.get_width() * .5) - 50
		sustain.scale.y = -1
		sustain.modulate.a = .6
		sustain.show_behind_parent = true
		sustain.material = load('res://game/materials/Sustain Clip.tres')
		add_child(sustain)
		
		end = Sprite2D.new()
		end.texture = load('res://assets/images/note/note_assets/' + col_arr[data.lane % 4] + ' hold end0000.png')
		end.position.y -= sustain.size.y + (end.texture.get_height() * .5)
		end.scale.y = -1
		end.modulate.a = .6
		end.show_behind_parent = true
		end.material = load('res://game/materials/Sustain Clip.tres')
		add_child(end)
		
func append_data(data:NoteData) -> void:
	if (data == null): return
	self.data.lane = data.lane % 4
	self.data.time = data.time
	self.data.length = data.length
	self.data.is_sustain = data.is_sustain
	self.data.must_hit = data.must_hit
		
func follow_strumline(strumline:Strumline) -> void:
	var receptor_pos:Array[float] = strumline.get_receptor_pos(data.lane)
	position = Vector2(receptor_pos[0], receptor_pos[1] + (Conductor.time - data.time) * (.45 * speed))
	if (data.is_sustain): sustain.material.set_shader_parameter('strum_coords', Vector2(receptor_pos[0], receptor_pos[1]))
