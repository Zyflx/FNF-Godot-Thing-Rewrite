extends Node

@onready var songs:PackedStringArray = DirAccess.get_directories_at('assets/songs')
@onready var container:VBoxContainer = $ScrollContainer/VBoxContainer

func _ready() -> void:
	Conductor.active = false
	for i in songs.size():
		init_song(songs[i], i)

func init_song(song:String, index:int) -> void:
	var button:Button = Button.new()
	button.add_theme_stylebox_override('normal', load('res://game/styles/MenuButton.tres'))
	button.text = song.to_pascal_case()
	button.pressed.connect(func():
		Chart.chart = Chart.load_chart(song)
		get_tree().change_scene_to_file('res://game/scenes/Game.tscn')
	)
	container.add_child(button)
