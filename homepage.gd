extends Control

class_name Homepage

var user_prefs: Dictionary
var user_prefs_path = "user://prefs.json"
var default_user_prefs = "res://default_user_prefs.json"

var startgg_api_key: String = ""


var get_event_id_qf = "res://commandhub/get_event_id.json"
var get_sets_in_event_qf = "res://commandhub/get_sets_in_event.json"
var complete_set_data_qf = "res://commandhub/complete_set_data.json"


var event_name: String = ""
var sets: Array[Dictionary] = []

func store_prefs():
	# check user prefs path
	var userpath = DirAccess.open("user://")
	if(! userpath.file_exists("prefs.json")):
		var defaultfile = FileAccess.open(default_user_prefs, FileAccess.READ)
		var default_str = defaultfile.get_as_text()
		defaultfile.close()
		var userfile = FileAccess.open(user_prefs_path, FileAccess.WRITE)
		userfile.store_string(default_str)
		userfile.close()
		print("created prefs file")
	var f = FileAccess.open(user_prefs_path, FileAccess.READ)
	user_prefs = JSON.parse_string(f.get_as_text())
	f.close()
	
	# update all fields (currently only one exists)
	user_prefs["startgg_api_key"] = startgg_api_key
	
	f = FileAccess.open(user_prefs_path, FileAccess.WRITE)
	f.store_string(JSON.stringify(user_prefs))
	f.close()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# check user prefs path
	var userpath = DirAccess.open("user://")
	print("prefs file exists?")
	print(userpath.file_exists("prefs.json"))
	if(! userpath.file_exists("prefs.json")):
		var defaultfile = FileAccess.open(default_user_prefs, FileAccess.READ)
		var default_str = defaultfile.get_as_text()
		defaultfile.close()
		var userfile = FileAccess.open(user_prefs_path, FileAccess.WRITE)
		userfile.store_string(default_str)
		userfile.close()
		print("created prefs file")
	var f = FileAccess.open(user_prefs_path, FileAccess.READ)
	user_prefs = JSON.parse_string(f.get_as_text())
	f.close()
	startgg_api_key = user_prefs["startgg_api_key"]
	
	$Background.show()
	$MainPage.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func get_event_id(slug: String) -> float:
	var f = FileAccess.open(get_event_id_qf, FileAccess.READ)
	var query_json = JSON.parse_string(f.get_as_text())
	f.close()
	
	# cleanup slug
	if(slug.find("tournament") == -1):
		# error invalid slug
		return(-2)
	if(slug.find("tournament") != 0):
		slug = slug.substr(slug.find("tournament"))
	
	query_json["variables"]["slug"] = slug
	
	
	var query = JSON.stringify(query_json, "")
	query = query.replace("\\t", "").replace("\\n", " ").replace("\"", "\\\"")
	
	var command_string = "curl -H \"Content-Type: application/json\" -H \"Authorization: Bearer " + startgg_api_key + "\" --request POST --data \"" + query + "\" https://api.start.gg/gql/alpha"
	
	print(command_string)
	
	var output = []
	var exit_code = OS.execute("cmd.exe", ["/c", command_string], output) # THIS WORKS
	
	
	var output_json = JSON.parse_string(output[0])
	print(output_json)
	
	if(output_json.has("success")):
		# unsuccessful
		if(output_json["message"] == "Invalid authentication token"):
			return(-1)
		return(-2)
	
	var event_id: float = 0
	event_id = output_json["data"]["event"]["id"]
	
	return(event_id)

func get_sets_in_event(event_id: float) -> float:
	var f = FileAccess.open(get_sets_in_event_qf, FileAccess.READ)
	var query_json = JSON.parse_string(f.get_as_text())
	f.close()
	
	
	query_json["variables"]["eventId"] = event_id
	
	
	
	var query = JSON.stringify(query_json, "")
	query = query.replace("\\t", "").replace("\\n", " ").replace("\"", "\\\"")
	
	var command_string = "curl -H \"Content-Type: application/json\" -H \"Authorization: Bearer " + startgg_api_key + "\" --request POST --data \"" + query + "\" https://api.start.gg/gql/alpha"
	
	#print(command_string)
	
	var output = []
	var exit_code = OS.execute("cmd.exe", ["/c", command_string], output) # THIS WORKS
	
	
	var output_json = JSON.parse_string(output[0])
	
	if(output_json.has("success")):
		# unsuccessful
		if(output_json["message"] == "Invalid authentication token"):
			return(-1)
		return(-2)
	
	
	sets = []
	var amount_of_sets: int = len(output_json["data"]["event"]["sets"]["nodes"])
	
	for i in range(amount_of_sets):
		#print(output_json["data"]["event"]["sets"]["nodes"][i]["fullRoundText"])
		#print(output_json["data"]["event"]["sets"]["nodes"][i]["slots"][0]["entrant"]["name"])
		#print(output_json["data"]["event"]["sets"]["nodes"][i]["slots"][1]["entrant"]["name"])
		
		sets.append(output_json["data"]["event"]["sets"]["nodes"][i])
	
	# success
	return(0)

func complete_set_data(set_id: float, set_obj: SetObj) -> float:
	var f = FileAccess.open(complete_set_data_qf, FileAccess.READ)
	var query_json = JSON.parse_string(f.get_as_text())
	f.close()
	
	
	query_json["variables"]["setId"] = set_id
	
	
	var query = JSON.stringify(query_json, "")
	query = query.replace("\\t", "").replace("\\n", " ").replace("\"", "\\\"")
	
	var command_string = "curl -H \"Content-Type: application/json\" -H \"Authorization: Bearer " + startgg_api_key + "\" --request POST --data \"" + query + "\" https://api.start.gg/gql/alpha"
	
	print(command_string)
	
	var output = []
	var exit_code = OS.execute("cmd.exe", ["/c", command_string], output) # THIS WORKS
	
	
	var output_json = JSON.parse_string(output[0])
	print(output_json)
	
	if(output_json.has("success")):
		# unsuccessful
		if(output_json["message"] == "Invalid authentication token"):
			return(-1)
		return(-2)
	
	set_obj.set_data = output_json["data"]["set"]
	set_obj.complete = true
	
	for set_data in sets:
		if(set_data["id"] == set_id):
			set_data = output_json["data"]["set"]
	
	# success
	return(0)



func setup_main_page():
	for set_data in sets:
		var set_obj = preload("res://set_obj.tscn").instantiate()
		set_obj.homepage = self
		set_obj.set_data = set_data
		set_obj.update_text()
		$MainPage/RightSide/ScrollContainer/VBoxContainer.add_child(set_obj)
	
	$MainPage/RightSide/TitleText.text = "[font_size=42][center]SETS (" + str(len(sets)) + ")[/center][/font_size]"
	$MainPage/LeftSide/TitleText.text = "[font_size=28][center]" + event_name + "[/center][/font_size]"



func _on_update_api_key_button_pressed() -> void:
	$Background/UpdateAPIKeyWindow.show()
	$Background/UpdateAPIKeyWindow/LineEdit.text = startgg_api_key

func _on_updateapikeywindow_x_button_pressed() -> void:
	$Background/UpdateAPIKeyWindow.hide()

func _on_updateapikeywindow_confirm_button_pressed() -> void:
	$Background/UpdateAPIKeyWindow.hide()
	startgg_api_key = $Background/UpdateAPIKeyWindow/LineEdit.text
	store_prefs()

func _on_initializationwindow_confirm_button_pressed() -> void:
	var event_id_result: float = get_event_id($Background/InitializationWindow/EventURLEntry.text)
	if(event_id_result == -1):
		$Background/InitializationWindow/InfoText.text = "[center]Request failed\nInvalid authentication token[/center]"
	elif(event_id_result == -2):
		$Background/InitializationWindow/InfoText.text = "[center]Request failed[/center]"
	elif(event_id_result == -3):
		$Background/InitializationWindow/InfoText.text = "[center]Invalid slug[/center]"
	else:
		var exit_code: float = get_sets_in_event(event_id_result)
		if(exit_code == -1):
			$Background/InitializationWindow/InfoText.text = "[center]Request failed\nInvalid authentication token[/center]"
		elif(exit_code == -2):
			$Background/InitializationWindow/InfoText.text = "[center]Request failed[/center]"
		elif(exit_code == 0):
			event_name = $Background/InitializationWindow/EventNameEntry.text
			$Background/InitializationWindow.hide()
			$Background.hide()
			$MainPage.show()
			setup_main_page()
