class_name Note extends AnimatedSprite2D

static var col_arr:Array[String] = ['purple', 'blue', 'green', 'red']
static var dir_arr:Array[String] = ['left', 'down', 'up', 'right']
static var swag_width:float = 160 * .7

var time:float = 0.0
var lane:int = 0
var length:float = 0.0
var is_sustain:bool = false
var must_hit:bool = false

var can_hit:bool = false:
	get: return must_hit and time >= Conductor.time - (166 * .8) and time <= Conductor.time + (166 * 1)
var can_cause_miss:bool = false:
	get: return position.y > get_viewport().size.y + 30
var was_good_hit:bool = false:
	get: return not must_hit and time <= Conductor.time

func _ready() -> void:
	scale = Vector2(.7, .7)
	play(col_arr[lane % 4])
