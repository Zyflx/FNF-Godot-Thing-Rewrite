class_name NoteSplash extends AnimatedSprite2D

func _ready() -> void:
	scale = Vector2(.7, .7)

func spawn_splash(note:Note) -> void:
	play('note impact %s %s' % [randi_range(0, 1) + 1, Note.col_arr[note.data.lane % 4]])
	animation_finished.connect(queue_free)
