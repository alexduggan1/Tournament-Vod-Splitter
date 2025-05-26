extends ColorRect

class_name SetObj


var set_data: Dictionary

var complete: bool = false


var homepage: Homepage

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	complete = false

func update_text():
	var p1Score: String = "?"
	var p2Score: String = "?"
	
	if(complete):
		color = Color(21.0/255, 32.0/255, 156.0/255)
		p1Score = str(int(set_data["slots"][0]["standing"]["stats"]["score"]["value"]))
		p2Score = str(int(set_data["slots"][1]["standing"]["stats"]["score"]["value"]))
	else:
		color = Color(21.0/255, 21.0/255, 21.0/255)
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_interact_button_pressed() -> void:
	homepage.complete_set_data(set_data["id"], self)
	update_text()
