class_name JudgeSprite extends FunkSprite

func _ready() -> void:
	active = true
	scale = Vector2(.7, .7)
	
func spawn(judgement:int) -> void:
	frame = absi(judgement - vframes)
	acceleration.y = 550
	velocity = Vector2(-randi_range(0, 10), -randi_range(140, 175))
