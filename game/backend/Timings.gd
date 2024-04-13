class_name Timings extends Node

# based off of https://github.com/CrowPlexus-FNF/Forever-Engine-Legacy/blob/master/source/meta/data/Timings.hx

enum JudgementData {UNDEFINED = 0, TIER1 = 1, TIER2 = 2, TIER3 = 3, TIER4 = 4, TIER5 = 5}

static var judgement_data:Dictionary = {
	# format: judgement name, timing window, accuracy modifier, score, health gain
	JudgementData.TIER5: ['swag', 22.5, 1, 400, .04],
	JudgementData.TIER4: ['sick', 45, .98, 350, .03],
	JudgementData.TIER3: ['good', 90, .75, 200, .023],
	JudgementData.TIER2: ['bad', 135, .4, 100, .015],
	JudgementData.TIER1: ['shit', 180, .15, 50, .01],
	JudgementData.UNDEFINED: ['undefined', 0, 0, 0, 0]
}

static var rank_map:Dictionary = {
	100: 'S+', 95: 'S',
	90: 'A', 85: 'B',
	80: 'C', 75: 'D',
	70: 'E'
}

static var worst_judge:Array = judgement_data[JudgementData.TIER1]

static var accuracy:float = 0.0
static var total:float = 0.0
static var played:int = 0

static func reset() -> void:
	accuracy = 0.0; total = 0.0; played = 0
	
static func update_accuracy(judgement:int = JudgementData.UNDEFINED, missed:bool = false) -> void:
	played += 1
	if (not missed): total += judgement_data[judgement][2]
	accuracy = (total / (played + Game.instance.misses)) * 100.0
	Game.instance.game_ui.update_score_txt()
	
static func determine_rank(acc:float = 0.0) -> String:
	for i in rank_map.keys():
		if (i <= acc):
			return rank_map[i]
	return 'N/A' if acc == 0.0 else 'F'

static func get_judgement(diff:float = -1) -> JudgementData:
	for i in judgement_data.keys():
		if (diff <= judgement_data[i][1]):
			return i
	return JudgementData.UNDEFINED
