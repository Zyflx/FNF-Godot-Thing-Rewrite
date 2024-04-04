class_name GameUI extends Node

@onready var game:Node2D = get_tree().current_scene
@onready var score_txt:Label = $ScoreTxt

var accuracy:float = 0.0
var total:float = 0.0
var played:int = 0

var rank_map:Dictionary = {
	100: 'S+', 95: 'S',
	90: 'A', 85: 'B',
	80: 'C', 75: 'D',
	70: 'E'
}

func _ready() -> void:
	score_txt.position = Vector2(400, 100)
	
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
