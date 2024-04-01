class_name Receptor extends AnimatedSprite2D

var lane:int = 0
var reset_time:float = 0.0
var is_player:bool = false

func _ready() -> void:
	scale = Vector2(.7, .7)
	position = Vector2(100 + (Note.swag_width * lane), get_viewport().size.y - 120)
	if (is_player): position.x += (get_viewport().size.x * .5) + 100
	play_anim('static')
	# animation_finished.connect(func(): play_anim('static'))

func _process(delta:float) -> void:
	if (reset_time > 0):
		reset_time -= delta
		if (reset_time <= 0):
			play_anim('static')
			reset_time = 0.0

func play_anim(anim:String) -> void:
	play(anim)
	if (anim == 'static'):
		frame = lane % 4
		
func dir_to_name() -> String:
	return Note.dir_arr[lane % 4]
