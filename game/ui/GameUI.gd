class_name GameUI extends Control

@onready var game:Node2D = get_tree().current_scene
@onready var score_txt:Label = $ScoreTxt
@onready var health_bar:ProgressBar = $HealthBar
@onready var plr_icon:HealthIcon = $PlayerIcon
@onready var cpu_icon:HealthIcon = $CPUIcon

var accuracy:float = 0.0
var total:float = 0.0
var played:int = 0

var health:float = 50.0

var rank_map:Dictionary = {
	100: 'S+', 95: 'S',
	90: 'A', 85: 'B',
	80: 'C', 75: 'D',
	70: 'E'
}

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
	health = lerpf(health, game.health, delta * 8)
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
	var acc:float = round_decimal(accuracy, 2)
	var rank:String = determine_rank(acc)
	var text:String = 'Score: %s | Misses: %s | Accuracy: [%s%% | %s]'
	score_txt.text = text % [game.score, game.misses, acc, rank]
	
func update_accuracy(judgement:int, missed:bool = false) -> void:
	played += 1
	if (not missed): total += game.judgement_data[judgement][2]
	accuracy = (total / (played + game.misses)) * 100.0
	update_score_txt()
	
func determine_rank(acc:float = 0.0) -> String:
	for i in rank_map.keys():
		if (i <= acc):
			return rank_map[i]
	return 'F' if acc <= 65 and acc > 0 else 'N/A'
	
func round_decimal(val:float, decimals:int) -> float:
	var mult:float = 1
	for i in decimals: mult *= 10
	return round(val * mult) / mult	
