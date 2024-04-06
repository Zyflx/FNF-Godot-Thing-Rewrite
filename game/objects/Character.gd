class_name Character extends AnimatedSprite2D

var _json:Variant

var cam_offset:Vector2 = Vector2.ZERO
var pos_offset:Vector2 = Vector2.ZERO

@export var is_player:bool = false
@export var is_gf:bool = false
@export var cur_char:String = 'bf'

var has_dance_anims:bool = false

var hold_tmr:float = 0.0
var sing_dur:float = 4.0

var sing_anims:Array[String] = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT']
var anim_offsets:Dictionary = {}

var danced:bool = false

func _ready() -> void:
	init_char(cur_char)
	centered = false
	if (not is_player and not is_gf): 
		scale.x *= -1
		# flip left and right
		sing_anims[0] = 'singRIGHT'
		sing_anims[3] = 'singLEFT'
	position.x += pos_offset.x
	position.y += pos_offset.y
	
func _process(delta:float) -> void:
	if (animation.contains('sing')): hold_tmr += delta
	if (hold_tmr >= Conductor.step_crochet * .0011 * sing_dur):
		dance()
		hold_tmr = 0.0
	
func init_char(char:String = 'bf') -> void:
	var path:String = 'res://assets/images/characters/%s/%s' % [char, char]
	_json = JSON.parse_string(FileAccess.open(path + '.json', FileAccess.READ).get_as_text())
	sprite_frames = load(path + '.res')
	
	for i in _json.animations.size():
		var anim:Dictionary = _json.animations[i]
		anim_offsets[anim.anim] = [-anim.offsets[0], -anim.offsets[1]]
		
	has_dance_anims = anim_offsets.has('danceLeft') and anim_offsets.has('danceRight')
	cam_offset = Vector2(_json.camera_position[0], _json.camera_position[1])
	pos_offset = Vector2(_json.position[0], _json.position[1])
	
	dance()
	
func dance() -> void:
	if (is_gf and has_dance_anims):
		danced = not danced
		play_anim('danceLeft' if danced else 'danceRight')
	else: if (anim_offsets.has('idle')): play_anim('idle')
			
func play_anim(anim:String, forced:bool = false) -> void:
	if (not anim_offsets.has(anim)): return
	var offsets:Array = anim_offsets[anim]
	play(anim)
	if (forced): frame = 0
	offset = Vector2(offsets[0], offsets[1])
	
func sing(dir:int = 0) -> void:
	var anim:String = sing_anims[dir % 4]
	hold_tmr = 0.0
	play_anim(anim, true)

func get_cam_pos() -> Vector2:
	var tex:Texture2D = sprite_frames.get_frame_texture('idle', 0)
	var midpoint:Vector2 = Vector2(position.x + tex.get_width() * .5, position.y + tex.get_height() * .5)
	var pos:Vector2 = Vector2(midpoint.x + (150 if not is_player else -100), midpoint.y - 100)
	pos.x += cam_offset.x - midpoint.x - 350 if not is_player else cam_offset.x
	pos.y += cam_offset.y
	return pos
