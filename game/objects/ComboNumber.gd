class_name ComboNumber extends FunkSprite

func _ready() -> void:
	active = true
	scale = Vector2(.5, .5)

func spawn(number:int = 0) -> void:
	texture = load('res://assets/images/ui/combo_numbers/num%s.png' % number)
	acceleration.y = randi_range(200, 300)
	velocity = Vector2(randf_range(-5, 5), -randi_range(140, 160))
