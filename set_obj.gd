extends ColorRect

class_name SetObj


var set_data: Dictionary

var complete: bool = false

var on_stream: bool = false
var start_time: int = 0
var end_time: int = 0

var exported: bool = false


var p1chars: Array = []
var p2chars: Array = []

var my_color: Color
var main_info_text = ""
var homepage: Homepage

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func update_text():
	var p1Score: String = "?"
	var p2Score: String = "?"
	
	if(complete):
		p1Score = str(int(set_data["slots"][0]["standing"]["stats"]["score"]["value"]))
		p2Score = str(int(set_data["slots"][1]["standing"]["stats"]["score"]["value"]))
	else:
		if(set_data["slots"][0]["standing"]["placement"] == 1):
			p1Score = "W"
			p2Score = "L"
		else:
			p1Score = "L"
			p2Score = "W"
	
	var p1DisplayName = set_data["slots"][0]["entrant"]["name"]
	var p2DisplayName = set_data["slots"][1]["entrant"]["name"]
	
	if(len(p1DisplayName) > 20): p1DisplayName = p1DisplayName.substr(0, 17) + "..."
	if(len(p2DisplayName) > 20): p2DisplayName = p2DisplayName.substr(0, 17) + "..."
	
	var finalText = "[font_size=20][center]" + set_data["fullRoundText"] + "\n"
	finalText = finalText + p1DisplayName + " " + p1Score + " - "
	finalText = finalText + p2Score + " " + p2DisplayName + "[/center][/font_size]"
	$TitleText.text = finalText
	main_info_text = finalText

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(homepage.current_set == self):
		my_color = Color(21.0/255.0, 32.0/255.0, 156.0/255.0)
	elif(exported):
		my_color = Color(48.0/255.0, 178.0/255.0, 75.0/255.0)
	elif(on_stream):
		my_color = Color(130.0/255.0, 29.0/255.0, 164.0/255.0)
	elif(complete):
		my_color = Color(59.0/255.0, 59.0/255.0, 59.0/255.0)
	else:
		my_color = Color(21.0/255.0, 21.0/255.0, 21.0/255.0)
	color = my_color

func find_player_chars():
	var p1ID = set_data["slots"][0]["entrant"]["id"]
	var p2ID = set_data["slots"][1]["entrant"]["id"]
	
	var p1charstemp: Array = []
	var p2charstemp: Array = []
	
	if(set_data["games"] != null):
		for i in range(len(set_data["games"])):
			var selections1 = set_data["games"][i]["selections"][0]
			var selections2 = set_data["games"][i]["selections"][1]
			
			if(p1ID == selections1["entrant"]["id"]):
				p1charstemp.append(selections1["character"]["name"])
				p2charstemp.append(selections2["character"]["name"])
			else:
				p2charstemp.append(selections1["character"]["name"])
				p1charstemp.append(selections2["character"]["name"])
		
		p1chars = []
		for char in p1charstemp:
			if (! p1chars.has(char)):
				p1chars.append(char)
		p2chars = []
		for char in p2charstemp:
			if (! p2chars.has(char)):
				p2chars.append(char)
		
		print(p1chars)
		print(p2chars)


func _on_interact_button_pressed() -> void:
	if(! complete):
		homepage.complete_set_data(set_data["id"], self)
		find_player_chars()
	
	update_text()
	homepage.set_current_set(self)
