class_name GameUI extends Control

@onready var score_txt:Label = $ScoreTxt
@onready var health_bar:ProgressBar = $HealthBar
@onready var plr_icon:HealthIcon = $PlayerIcon
@onready var cpu_icon:HealthIcon = $CPUIcon

var health:float = 50.0

func _ready() -> void:
	health_bar.position = Vector2(350, 50)
	score_txt.position = Vector2(400, 100)
	pivot_offset = Vector2(
		(get_viewport_rect().size.x - size.x) * .5,
		(get_viewport_rect().size.y - size.y) * .5
	)
	plr_icon.position.y = health_bar.position.y + (health_bar.get_child(0).texture.get_height() * .5)
	cpu_icon.position.y = health_bar.position.y + (health_bar.get_child(0).texture.get_height() * .5)
	
func _process(delta:float) -> void:
	health = lerpf(health, Game.instance.health, delta * 8)
	health_bar.value = health
	
	var bar_size:float = lerpf(0, health_bar.size.x, 1 - health_bar.value * .01)
	var center:float = health_bar.position.x + bar_size + 75
	
	plr_icon.position.x = center + (150 * plr_icon.scale.x - 150) * .5 - 26 
	cpu_icon.position.x = center - (150 * cpu_icon.scale.x) * .5 - 26 * 2
	
	plr_icon.frame = 1 if health_bar.value < 20 else 0
	cpu_icon.frame = 1 if health_bar.value > 80 else 0
	
func icon_bump() -> void:
	plr_icon.bump()
	cpu_icon.bump()
	
func update_score_txt() -> void:
	var acc:float = Util.round_decimal(Timings.accuracy, 2)
	var rank:String = Timings.determine_rank(acc)
	var text:String = 'Score: %s | Misses: %s | Accuracy: [%s%% | %s]'
	score_txt.text = text % [Game.instance.score, Game.instance.misses, acc, rank]
