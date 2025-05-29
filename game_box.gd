extends ColorRect

class_name GameBox

var set_data: Dictionary
var game_num: int

var set_obj: SetObj
var homepage: Homepage

func setup():
	$GameNum.text = "[font_size=24][center]Game " + str(game_num+1) + "[/center][/font_size]"
	
	var p1ID = set_data["slots"][0]["entrant"]["id"]
	var p2ID = set_data["slots"][1]["entrant"]["id"]
	
	
	var selections1 = set_data["games"][game_num]["selections"][0]
	var selections2 = set_data["games"][game_num]["selections"][1]
	
	print(selections1)
	
	$P1Char.text = "[font_size=20][center]" + selections1["character"]["name"] + "[/center][/font_size]"
	$P2Char.text = "[font_size=20][center]" + selections2["character"]["name"] + "[/center][/font_size]"
	
	if(p1ID == selections1["entrant"]["id"]):
		# selections1 on left
		$P1Char.text = "[font_size=20][center]" + selections1["character"]["name"] + "[/center][/font_size]"
		$P2Char.text = "[font_size=20][center]" + selections2["character"]["name"] + "[/center][/font_size]"
	else:
		# selections1 on right
		$P2Char.text = "[font_size=20][center]" + selections1["character"]["name"] + "[/center][/font_size]"
		$P1Char.text = "[font_size=20][center]" + selections2["character"]["name"] + "[/center][/font_size]"
		#print("order not as expected")
	
	var winnerID = set_data["games"][game_num]["winnerId"]
	
	if(winnerID == p1ID):
		$P1Result.text = "[font_size=24][center][color=green]W[/color][/center][/font_size]"
		$P2Result.text = "[font_size=24][center][color=red]L[/color][/center][/font_size]"
	else:
		$P2Result.text = "[font_size=24][center][color=green]W[/color][/center][/font_size]"
		$P1Result.text = "[font_size=24][center][color=red]L[/color][/center][/font_size]"

func _process(delta: float) -> void:
	if(homepage.current_set != set_obj):
		queue_free()
