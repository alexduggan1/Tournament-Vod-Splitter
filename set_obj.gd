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
		color = Color(21.0/255, 32.0/255, 76.0/255)
		p1Score = str(set_data["slots"][0]["standing"]["stats"]["score"]["value"])
		p2Score = str(set_data["slots"][1]["standing"]["stats"]["score"]["value"])
	else:
		color = Color(21.0/255, 21.0/255, 21.0/255)
		if(set_data["slots"][0]["standing"]["placement"] == 1):
			p1Score = "W"
			p2Score = "L"
		else:
			p1Score = "L"
			p2Score = "W"
	
	var finalText = "[font_size=20][center]" + set_data["fullRoundText"] + "\n"
	finalText = finalText + set_data["slots"][0]["entrant"]["name"].substr(0,20) + " " + p1Score + " - "
	finalText = finalText + p2Score + " " + set_data["slots"][1]["entrant"]["name"].substr(0,20) + "[/center][/font_size]"
	$TitleText.text = finalText
	
	color = Color(21.0/255, 21.0/255, 21.0/255)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_interact_button_pressed() -> void:
	homepage.complete_set_data(set_data["id"], self)
	update_text()
