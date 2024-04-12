class_name HealthIcon extends Sprite2D

@export var is_player:bool = false

var health_val:float = 0.0

func _ready() -> void:
	texture = load('res://assets/images/ui/health_icon.png')
	flip_h = is_player
	hframes = 2

func _process(delta:float) -> void:
	var lerp_val:float = lerpf(1, scale.x, exp(-delta * 20))
	scale = Vector2(lerp_val, lerp_val)
	position.y = -position.y + (position.y * scale.y) + 59.5

func bump() -> void:
	scale = Vector2(1.2, 1.2)
