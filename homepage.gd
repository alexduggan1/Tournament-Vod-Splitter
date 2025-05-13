extends Control

var user_prefs: Dictionary
var user_prefs_path = "user://prefs.json"
var default_user_prefs = "res://default_user_prefs.json"

var startgg_api_key: String = ""


var get_event_id_qf = "res://commandhub/get_event_id.json"
var get_sets_in_event_qf = "res://commandhub/get_sets_in_event.json"


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
	
	
	var event_id: float = 0
	event_id = get_event_id()
	print(event_id)
	
	get_sets_in_event(event_id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func get_event_id() -> float:
	var f = FileAccess.open(get_event_id_qf, FileAccess.READ)
	var query_json = JSON.parse_string(f.get_as_text())
	f.close()
	
	
	var slug: String = "https://www.start.gg/tournament/smash-at-wpi-135/event/ultimate-singles"
	
	# cleanup slug
	if(slug.find("tournament") != 0):
		slug = slug.substr(slug.find("tournament"))
	
	
	query_json["variables"]["slug"] = slug
	
	
	var query = JSON.stringify(query_json, "")
	query = query.replace("\\t", "").replace("\\n", " ").replace("\"", "\\\"")
	
	var command_string = "curl -H \"Content-Type: application/json\" -H \"Authorization: Bearer " + startgg_api_key + "\" --request POST --data \"" + query + "\" https://api.start.gg/gql/alpha"
	
	print(command_string)
	
	var output = []
	var exit_code = OS.execute("cmd.exe", ["/c", command_string], output) # THIS WORKS
	
	
	#var exit_code = OS.execute("cmd.exe", ["/c", "curl", "-H", "\"Content-Type: application/json\"", "-H", authorization_arg, "--request", "POST", "--data", data_arg, "https://api.start.gg/gql/alpha"], output, false, true)
	#var exit_code = OS.execute("cmd.exe", ["/c", "curl", "--help"], output, false, true)
	
	
	print(output)
	
	print(output[0])
	
	var output_json = JSON.parse_string(output[0])
	print(output_json)
	
	var event_id: float = 0
	event_id = output_json["data"]["event"]["id"]
	
	return(event_id)

func get_sets_in_event(event_id: float):
	var f = FileAccess.open(get_sets_in_event_qf, FileAccess.READ)
	var query_json = JSON.parse_string(f.get_as_text())
	f.close()
	
	
	query_json["variables"]["eventId"] = event_id
	
	
	
	var query = JSON.stringify(query_json, "")
	query = query.replace("\\t", "").replace("\\n", " ").replace("\"", "\\\"")
	
	var command_string = "curl -H \"Content-Type: application/json\" -H \"Authorization: Bearer " + startgg_api_key + "\" --request POST --data \"" + query + "\" https://api.start.gg/gql/alpha"
	
	print(command_string)
	
	var output = []
	var exit_code = OS.execute("cmd.exe", ["/c", command_string], output) # THIS WORKS
	
	
	#var exit_code = OS.execute("cmd.exe", ["/c", "curl", "-H", "\"Content-Type: application/json\"", "-H", authorization_arg, "--request", "POST", "--data", data_arg, "https://api.start.gg/gql/alpha"], output, false, true)
	#var exit_code = OS.execute("cmd.exe", ["/c", "curl", "--help"], output, false, true)
	
	
	#print(output)
	
	print(output[0])
	
	var output_json = JSON.parse_string(output[0])
	print(output_json)
	
	
	var amount_of_sets: int = len(output_json["data"]["event"]["sets"]["nodes"])
	print(len(output_json["data"]["event"]["sets"]["nodes"]))
	
	for i in range(amount_of_sets):
		print(output_json["data"]["event"]["sets"]["nodes"][i]["fullRoundText"])
		print(output_json["data"]["event"]["sets"]["nodes"][i]["slots"][0]["entrant"]["name"])
		print(output_json["data"]["event"]["sets"]["nodes"][i]["slots"][1]["entrant"]["name"])
		
		sets.append(output_json["data"]["event"]["sets"]["nodes"][i])
	

func _on_update_api_key_button_pressed() -> void:
	$Background/UpdateAPIKeyWindow.show()
	$Background/UpdateAPIKeyWindow/LineEdit.text = startgg_api_key

func _on_updateapikeywindow_x_button_pressed() -> void:
	$Background/UpdateAPIKeyWindow.hide()

func _on_updateapikeywindow_confirm_button_pressed() -> void:
	$Background/UpdateAPIKeyWindow.hide()
	startgg_api_key = $Background/UpdateAPIKeyWindow/LineEdit.text
	store_prefs()
