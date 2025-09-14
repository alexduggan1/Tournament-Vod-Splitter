extends Control

class_name Homepage

var character_art_dir: String = "C:/Users/Junii/Desktop/Important/SSBU/Character Renders/"

var user_prefs: Dictionary
var user_prefs_path = "user://prefs.json"
var default_user_prefs = "res://default_user_prefs.json"

var startgg_api_key: String = ""
var project_parent_path: String = ""


# query files
var get_event_id_qf = "res://commandhub/get_event_id.json"
var get_sets_in_event_qf = "res://commandhub/get_sets_in_event.json"
var complete_set_data_qf = "res://commandhub/complete_set_data.json"


# stuff to store about each project
var project_name: String = ""
var startgg_link: String = ""
var video_url: String = ""
var sets: Array[Dictionary] = []
var proj_path: String = ""
var thumbnail_title: String = ""


var customizing_thumbnail: bool = false

var current_set: SetObj = null

var project_open: bool = false


var player_mains_dict: Dictionary = {
	"juni": "Greninja",
	"turkeyboy2012": "Min Min",
	"saxaslayer": "Isabelle",
	"wright": "Falco",
	"hermanvi": "Mii Swordfighter",
	"unlimited will": "Captain Falcon",
	"mightybird": "Kirby",
	"piranha": "piranha plant",
	"sneezles": "Ken",
	"blucket": "Corrin",
	"meili": "Palutena",
	"araneae": "Ice Climbers",
	"birdthorn": "Ike",
	"j3ll0": "Random Character",
}


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
	
	# update all fields
	user_prefs["startgg_api_key"] = startgg_api_key
	user_prefs["project_parent_path"] = project_parent_path
	
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
	project_parent_path = user_prefs["project_parent_path"]
	
	$Background.show()
	$Background/UpdateAPIKeyWindow.hide()
	$RightSide.hide()
	$LeftSide.hide()
	$LeftSide/ThumbnailPane/SuccessIndicator.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(project_open):
		project_name = $LeftSide/ProjectPane/ProjectNameEdit.text
		thumbnail_title = $LeftSide/ProjectPane/ThumbnailTitleEdit.text
		# Set Details
		if(current_set != null):
			$LeftSide/SetDetailsPane.show()
			$LeftSide/SetDetailsPane/MainInfo.text = current_set.main_info_text
			current_set.on_stream = $LeftSide/SetDetailsPane/StreamedToggle.button_pressed
			if(current_set.on_stream):
				$LeftSide/SetDetailsPane/StartTimeBox.show()
				$LeftSide/SetDetailsPane/EndTimeBox.show()
			else:
				$LeftSide/SetDetailsPane/StartTimeBox.hide()
				$LeftSide/SetDetailsPane/EndTimeBox.hide()
		else:
			$LeftSide/SetDetailsPane.hide()
		
		$LeftSide/ThumbnailPane/SubViewportContainer/SubViewport/TitleTextHolder/ThumbnailTitle.text = "[font_size=50][center][b]" + thumbnail_title + "[/b][/center][/font_size]"
		
		if(customizing_thumbnail):
			$LeftSide/ThumbnailPane/SubViewportContainer/SubViewport/RoundNameHolder/RoundName.text = "[font_size=32][center][b]" + $LeftSide/ThumbnailPane/RoundNameEdit.text + "[/b][/center][/font_size]"
			
			$LeftSide/ThumbnailPane/SubViewportContainer/SubViewport/PlayerNamesHolder/P1NameHolder/P1Name.text = "[font_size=62][center][b]" + $LeftSide/ThumbnailPane/P1NameEdit.text + "[/b][/center][/font_size]"
			$LeftSide/ThumbnailPane/SubViewportContainer/SubViewport/PlayerNamesHolder/P2NameHolder/P2Name.text = "[font_size=62][center][b]" + $LeftSide/ThumbnailPane/P2NameEdit.text + "[/b][/center][/font_size]"
			
			$LeftSide/ThumbnailPane/SubViewportContainer/SubViewport/LeftZone/P1Char.flip_h = $LeftSide/ThumbnailPane/P1Flip.button_pressed
			$LeftSide/ThumbnailPane/SubViewportContainer/SubViewport/RightZone/P2Char.flip_h = $LeftSide/ThumbnailPane/P2Flip.button_pressed
		
		if(Input.is_action_just_pressed("save")):
			save_project()
	



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
	
	
	query_json["variables"]["eventId"] = int(event_id)
	
	
	
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
	
	print(output_json)
	
	print(output_json["data"])
	
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
	
	
	query_json["variables"]["setId"] = int(set_id)
	
	
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
		set_obj.complete = false
		set_obj.on_stream = false
		set_obj.start_time = 0
		set_obj.end_time = 0
		set_obj.exported = false
		set_obj.p1chars = []
		set_obj.p2chars = []
		set_obj.update_text()
		$RightSide/ScrollContainer/VBoxContainer.add_child(set_obj)
	
	$RightSide/TitleText.text = "[font_size=42][center]SETS (" + str(len(sets)) + ")[/center][/font_size]"
	$LeftSide/ProjectPane/ProjectNameEdit.text = project_name
	$LeftSide/ProjectPane/ThumbnailTitleEdit.text = thumbnail_title
	project_open = true


func set_current_set(setObj: SetObj):
	$LeftSide/SetDetailsPane/StreamedToggle.button_pressed = setObj.on_stream
	$LeftSide/SetDetailsPane/StartTimeBox.text = str(setObj.start_time)
	$LeftSide/SetDetailsPane/EndTimeBox.text = str(setObj.end_time)
	
	print(setObj.set_data["games"])
	if(setObj.set_data["games"] != null):
		for i in range(len(setObj.set_data["games"])):
			var game_box = preload("res://game_box.tscn").instantiate()
			game_box.homepage = self
			game_box.set_obj = setObj
			game_box.set_data = setObj.set_data
			game_box.game_num = i
			game_box.setup()
			$LeftSide/SetDetailsPane/GamesContainer.add_child(game_box)
	
	if(! setObj.exported):
		$LeftSide/ThumbnailPane/SuccessIndicator.hide()
	current_set = setObj
	
	customizing_thumbnail = false

func create_project():
	print(project_name)
	
	proj_path = project_parent_path + project_name + "/"
	print(proj_path)
	
	DirAccess.make_dir_absolute(proj_path)
	DirAccess.make_dir_absolute(proj_path + "/videos")
	DirAccess.make_dir_absolute(proj_path + "/thumbnails")
	
	if(FileAccess.file_exists(proj_path + "proj.tvs")):
		print("file already exists")
		print("overwriting proj.tvs")
	
	# create proj.tvs
	var save_file = FileAccess.open(proj_path + "proj.tvs", FileAccess.WRITE)
	
	var save_dict: Dictionary = {
		"project_name": project_name,
		"startgg_link": startgg_link,
		"video_url": video_url,
		"sets": [],
		"proj_path": proj_path,
		"thumbnail_title": thumbnail_title
	}
	
	for i in range(len(sets)):
		save_dict["sets"].append({
			"set_data": sets[i],
			"complete": false,
			"on_stream": false,
			"start_time": 0,
			"end_time": 0,
			"exported": false,
			"p1chars": [],
			"p2chars": []
		})
	
	save_file.store_string(JSON.stringify(save_dict))
	save_file.close()

func save_project() -> void:
	print(project_name)
	
	var new_proj_path = project_parent_path + project_name + "/"
	print(new_proj_path)
	
	if(proj_path != new_proj_path):
		DirAccess.rename_absolute(proj_path, new_proj_path)
		proj_path = new_proj_path
	
	
	if(FileAccess.file_exists(proj_path + "proj.tvs")):
		print("file already exists")
		print("overwriting proj.tvs (because it is a save)")
	
	# create proj.tvs
	var save_file = FileAccess.open(proj_path + "proj.tvs", FileAccess.WRITE)
	
	var save_dict: Dictionary = {
		"project_name": project_name,
		"startgg_link": startgg_link,
		"video_url": video_url,
		"sets": [],
		"proj_path": proj_path,
		"thumbnail_title": thumbnail_title
	}
	
	for i in range(len($RightSide/ScrollContainer/VBoxContainer.get_children())):
		save_dict["sets"].append({
			"set_data": $RightSide/ScrollContainer/VBoxContainer.get_child(i).set_data,
			"complete": $RightSide/ScrollContainer/VBoxContainer.get_child(i).complete,
			"on_stream": $RightSide/ScrollContainer/VBoxContainer.get_child(i).on_stream,
			"start_time": $RightSide/ScrollContainer/VBoxContainer.get_child(i).start_time,
			"end_time": $RightSide/ScrollContainer/VBoxContainer.get_child(i).end_time,
			"exported": $RightSide/ScrollContainer/VBoxContainer.get_child(i).exported,
			"p1chars": $RightSide/ScrollContainer/VBoxContainer.get_child(i).p1chars,
			"p2chars": $RightSide/ScrollContainer/VBoxContainer.get_child(i).p2chars,
		})
	
	save_file.store_string(JSON.stringify(save_dict))
	save_file.close()

func open_project(path: String) -> void:
	var f = FileAccess.open(path, FileAccess.READ)
	var save_dict = JSON.parse_string(f.get_as_text())
	f.close()
	
	project_name = save_dict["project_name"]
	startgg_link = save_dict["startgg_link"]
	video_url = save_dict["video_url"]
	proj_path = save_dict["proj_path"]
	thumbnail_title = save_dict["thumbnail_title"]
	
	for i in range(len(save_dict["sets"])):
		var set_obj = preload("res://set_obj.tscn").instantiate()
		set_obj.homepage = self
		set_obj.set_data = save_dict["sets"][i]["set_data"]
		set_obj.complete = save_dict["sets"][i]["complete"]
		set_obj.on_stream = save_dict["sets"][i]["on_stream"]
		set_obj.start_time = save_dict["sets"][i]["start_time"]
		set_obj.end_time = save_dict["sets"][i]["end_time"]
		set_obj.exported = save_dict["sets"][i]["exported"]
		set_obj.p1chars = save_dict["sets"][i]["p1chars"]
		set_obj.p2chars = save_dict["sets"][i]["p2chars"]
		set_obj.update_text()
		$RightSide/ScrollContainer/VBoxContainer.add_child(set_obj)
	
	$RightSide/TitleText.text = "[font_size=42][center]SETS (" + str(len(sets)) + ")[/center][/font_size]"
	$LeftSide/ProjectPane/ProjectNameEdit.text = project_name
	$LeftSide/ProjectPane/ThumbnailTitleEdit.text = thumbnail_title
	project_open = true
	
	$Background.hide()
	$LeftSide.show()
	$RightSide.show()


func _on_generate_thumbnail_button_pressed() -> void:
	if(current_set != null):
		var set_data = current_set.set_data
		
		# do the round name
		
		var round_name = ""
		print(set_data["fullRoundText"])
		if(set_data["fullRoundText"].to_lower() == "grand final"):
			round_name = "GRAND FINALS"
		elif(set_data["fullRoundText"].to_lower() == "winners final"):
			round_name = "WINNERS FINALS"
		elif(set_data["fullRoundText"].to_lower() == "losers final"):
			round_name = "LOSERS FINALS"
		elif(set_data["fullRoundText"].to_lower() == "winners semi-final"):
			round_name = "WINNERS SEMIS"
		elif(set_data["fullRoundText"].to_lower() == "losers semi-final"):
			round_name = "LOSERS SEMIS"
		elif(set_data["fullRoundText"].to_lower() == "losers quarter-final"):
			round_name = "LOSERS QUARTERS"
		elif(set_data["fullRoundText"].to_lower() == "winners quarter-final"):
			round_name = "WINNERS QUARTERS"
		elif(! (set_data["fullRoundText"].to_lower().contains("winners") or set_data["fullRoundText"].to_lower().contains("losers"))):
			round_name = "POOLS"
		else:
			round_name = set_data["fullRoundText"].to_upper()
		
		print(round_name)
		$LeftSide/ThumbnailPane/SubViewportContainer/SubViewport/RoundNameHolder/RoundName.text = "[font_size=32][center][b]" + round_name + "[/b][/center][/font_size]"
		
		$LeftSide/ThumbnailPane/RoundNameEdit.text = round_name
		
		# do the player names
		
		var p1DisplayName: String = set_data["slots"][0]["entrant"]["name"]
		var p2DisplayName: String = set_data["slots"][1]["entrant"]["name"]
		
		if(p1DisplayName.contains("|")):
			p1DisplayName = p1DisplayName.substr(p1DisplayName.find("|") + 2)
		if(p2DisplayName.contains("|")):
			p2DisplayName = p2DisplayName.substr(p2DisplayName.find("|") + 2)
		
		if(len(p1DisplayName) > 20): p1DisplayName = p1DisplayName.substr(0, 17) + "..."
		if(len(p2DisplayName) > 20): p2DisplayName = p2DisplayName.substr(0, 17) + "..."
		
		$LeftSide/ThumbnailPane/SubViewportContainer/SubViewport/PlayerNamesHolder/P1NameHolder/P1Name.text = "[font_size=62][center][b]" + p1DisplayName + "[/b][/center][/font_size]"
		$LeftSide/ThumbnailPane/SubViewportContainer/SubViewport/PlayerNamesHolder/P2NameHolder/P2Name.text = "[font_size=62][center][b]" + p2DisplayName + "[/b][/center][/font_size]"
		
		
		# do the characters now
		
		print(current_set.p1chars)
		print(current_set.p2chars)
		
		if(len(current_set.p1chars) == 0): $LeftSide/ThumbnailPane/SubViewportContainer/SubViewport/LeftZone/P1Char.texture = null
		else:
			var image = Image.load_from_file(character_art_dir + current_set.p1chars[0] + ".png")
			var texture = ImageTexture.create_from_image(image)
			$LeftSide/ThumbnailPane/SubViewportContainer/SubViewport/LeftZone/P1Char.texture = texture
		
		if(len(current_set.p2chars) == 0): $LeftSide/ThumbnailPane/SubViewportContainer/SubViewport/RightZone/P2Char.texture = null
		else:
			var image = Image.load_from_file(character_art_dir + current_set.p2chars[0] + ".png")
			var texture = ImageTexture.create_from_image(image)
			$LeftSide/ThumbnailPane/SubViewportContainer/SubViewport/RightZone/P2Char.texture = texture
		
		# provide customization options
		
		$LeftSide/ThumbnailPane/P1NameEdit.text = p1DisplayName
		$LeftSide/ThumbnailPane/P2NameEdit.text = p2DisplayName
		
		$LeftSide/ThumbnailPane/P1Flip.button_pressed = false
		$LeftSide/ThumbnailPane/P2Flip.button_pressed = false
		
		
		# round name editor
		
		
		
		customizing_thumbnail = true


func _on_p_1_select_art_button_pressed() -> void:
	$LeftSide/ThumbnailPane/P1SelectArtButton/FileDialog.current_dir = character_art_dir
	$LeftSide/ThumbnailPane/P1SelectArtButton/FileDialog.show()

func select_p1_charart(path: String) -> void:
	var image = Image.load_from_file(path)
	var texture = ImageTexture.create_from_image(image)
	$LeftSide/ThumbnailPane/SubViewportContainer/SubViewport/LeftZone/P1Char.texture = texture

func _on_p_2_select_art_button_pressed() -> void:
	$LeftSide/ThumbnailPane/P2SelectArtButton/FileDialog.current_dir = character_art_dir
	$LeftSide/ThumbnailPane/P2SelectArtButton/FileDialog.show()

func select_p2_charart(path: String) -> void:
	var image = Image.load_from_file(path)
	var texture = ImageTexture.create_from_image(image)
	$LeftSide/ThumbnailPane/SubViewportContainer/SubViewport/RightZone/P2Char.texture = texture


func capture_thumbnail():
	if(current_set != null):
		var save_path: String = ""
		var exp_name = get_export_name(current_set)
		
		if(exp_name.is_valid_filename()):
			save_path = proj_path + "thumbnails/" + exp_name + ".png"
		else:
			save_path = proj_path + "thumbnails/" + "workaround.png"
			print(proj_path + "thumbnails/" + exp_name + ".png")
		print(save_path)
		
		$LeftSide/ThumbnailPane/SubViewportContainer/SubViewport.get_texture().get_image().save_png(save_path)

func get_export_name(set_obj: SetObj) -> String:
	var export_name: String = project_name
	
	var set_data = set_obj.set_data
	# add round name
	var round_name = ""
	print(set_data["fullRoundText"])
	if(set_data["fullRoundText"].to_lower() == "grand final"):
		round_name = "GRAND FINALS"
	elif(set_data["fullRoundText"].to_lower() == "winners final"):
		round_name = "WINNERS FINALS"
	elif(set_data["fullRoundText"].to_lower() == "losers final"):
		round_name = "LOSERS FINALS"
	elif(set_data["fullRoundText"].to_lower() == "winners semi-final"):
		round_name = "WINNERS SEMIS"
	elif(set_data["fullRoundText"].to_lower() == "losers semi-final"):
		round_name = "LOSERS SEMIS"
	elif(set_data["fullRoundText"].to_lower() == "losers quarter-final"):
		round_name = "LOSERS QUARTERS"
	elif(set_data["fullRoundText"].to_lower() == "winners quarter-final"):
		round_name = "WINNERS QUARTERS"
	elif(! (set_data["fullRoundText"].to_lower().contains("winners") or set_data["fullRoundText"].to_lower().contains("losers"))):
		round_name = "POOLS"
	else:
		round_name = set_data["fullRoundText"].to_upper()
	
	if(round_name == ""):
		export_name = export_name + " - "
	else:
		export_name = export_name + " " + round_name + " - "
	
	# add player names
	var player_section = ""
	
	var p1DisplayName: String = set_data["slots"][0]["entrant"]["name"]
	var p2DisplayName: String = set_data["slots"][1]["entrant"]["name"]
	
	if(p1DisplayName.contains("|")):
		p1DisplayName = p1DisplayName.substr(p1DisplayName.find("|") + 2)
	if(p2DisplayName.contains("|")):
		p2DisplayName = p2DisplayName.substr(p2DisplayName.find("|") + 2)
	
	p1DisplayName = p1DisplayName.replace("/", "")
	p2DisplayName = p2DisplayName.replace("/", "")
	
	if(len(p1DisplayName) > 20): p1DisplayName = p1DisplayName.substr(0, 17)
	if(len(p2DisplayName) > 20): p2DisplayName = p2DisplayName.substr(0, 17)
	
	player_section += p1DisplayName
	
	if(len(set_obj.p1chars) == 0): player_section += " "
	else:
		player_section += " ("
		if(len(set_obj.p1chars) == 1): player_section += set_obj.p1chars[0]
		else:
			for i in range(len(set_obj.p1chars)-1):
				player_section += set_obj.p1chars[i] + ", "
			player_section += set_obj.p1chars[-1]
		player_section += ") "
	player_section += "Vs "
	
	player_section += p2DisplayName
	
	if(len(set_obj.p2chars) == 0): player_section += " "
	else:
		player_section += " ("
		if(len(set_obj.p2chars) == 1): player_section += set_obj.p2chars[0]
		else:
			for i in range(len(set_obj.p2chars)-1):
				player_section += set_obj.p2chars[i] + ", "
			player_section += set_obj.p2chars[-1]
		player_section += ")"
	
	export_name = export_name + player_section
	print(export_name)
	return(export_name)



func _on_download_all_streamed_button_pressed() -> void:
	for i in range(len($RightSide/ScrollContainer/VBoxContainer.get_children())):
		var to_download: SetObj = $RightSide/ScrollContainer/VBoxContainer.get_child(i)
		if(to_download.on_stream):
			if(! to_download.exported):
				download_set(to_download)

func _on_download_video_button_pressed() -> void:
	if (current_set != null):
		download_set(current_set)

func download_set(set_to_download: SetObj):
	if (set_to_download.start_time == 0 and set_to_download.end_time == 0):
		print("invalid start/end time")
		return
	
	print("downloading set")
	
	$LeftSide/ThumbnailPane/SuccessIndicator.show()
	$LeftSide/ThumbnailPane/SuccessIndicator.text = "[font_size=20][center]download started[/center][/font_size]"
	
	var dl_start = int(set_to_download.start_time)
	dl_start = clampi(dl_start-5, 0, dl_start)
	
	var command_string = "cd \"" + project_parent_path + "\" && yt-dlp -P \"" + proj_path + "videos/\" -o \"" + get_export_name(set_to_download)
	command_string += ".%(ext)s\" --download-sections *" + str(dl_start) + "-" + str(set_to_download.end_time) + " -f \"bv*+ba/b\" "
	#command_string += "--concurrent-fragments 4 --verbose "
	command_string += "\"" + video_url + "\""
	
	print(command_string)
	
	
	var output = []
	var exit_code = 0
	#exit_code = OS.execute("cmd.exe", ["/c", command_string], output, false, true)
	
	OS.create_process("cmd.exe", ["/c", command_string], true)
	
	#var exit_dict = OS.execute_with_pipe("cmd.exe", ["/c", command_string], true)
	#print(exit_dict)
	
	print(exit_code)
	print(output)
	
	set_to_download.exported = true;

func _on_update_ytdlp_button_pressed() -> void:
	var command_string = "cd \"" + project_parent_path + "\" && yt-dlp -U"
	
	print(command_string)
	
	OS.create_process("cmd.exe", ["/c", command_string], true)



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
			project_name = $Background/InitializationWindow/ProjectNameEntry.text
			print(project_name)
			if(! project_name.is_valid_filename()):
				$Background/InitializationWindow/InfoText.text = "[center]Invalid project name[/center]"
				project_name = ""
			elif(DirAccess.dir_exists_absolute(project_parent_path + project_name + "/")):
				$Background/InitializationWindow/InfoText.text = "[center]Project name already exists[/center]"
				project_name = ""
			else:
				project_name = $Background/InitializationWindow/ProjectNameEntry.text
				thumbnail_title = project_name
				startgg_link = $Background/InitializationWindow/EventURLEntry.text
				video_url = $Background/InitializationWindow/VideoURLEntry.text
				$Background/InitializationWindow.hide()
				$Background.hide()
				$RightSide.show()
				$LeftSide.show()
				create_project()
				setup_main_page()

func _on_updateapikeywindow_file_dialog_dir_selected(dir: String) -> void:
	print(dir)
	project_parent_path = dir + "/"

func _on_updateapikey_edit_proj_parent_path_pressed() -> void:
	if(DirAccess.dir_exists_absolute(project_parent_path)):
		$Background/UpdateAPIKeyWindow/EditProjParentPath/FileDialog.current_path = project_parent_path
	$Background/UpdateAPIKeyWindow/EditProjParentPath/FileDialog.show()

func _on_start_time_box_text_changed(new_text: String) -> void:
	var success: bool = false
	if(new_text.is_valid_int()):
		current_set.start_time = int(new_text)
		success = true
	else:
		print(new_text)
		if(new_text.to_lower().contains("youtu")):
			if(new_text.to_lower().contains("?t=")):
				var numstart: int = new_text.find("?t=") + 3
				print(new_text.substr(numstart))
				if(new_text.substr(numstart).is_valid_int()):
					current_set.start_time = int(new_text.substr(numstart))
					$LeftSide/SetDetailsPane/StartTimeBox.text = str(current_set.start_time)
					success = true
	if(! success):
		$LeftSide/SetDetailsPane/StartTimeBox.text = ""

func _on_end_time_box_text_changed(new_text: String) -> void:
	var success: bool = false
	if(new_text.is_valid_int()):
		current_set.end_time = int(new_text)
		success = true
	else:
		print(new_text)
		if(new_text.to_lower().contains("youtu")):
			if(new_text.to_lower().contains("?t=")):
				var numstart: int = new_text.find("?t=") + 3
				print(new_text.substr(numstart))
				if(new_text.substr(numstart).is_valid_int()):
					current_set.end_time = int(new_text.substr(numstart))
					$LeftSide/SetDetailsPane/EndTimeBox.text = str(current_set.end_time)
					success = true
	if(! success):
		$LeftSide/SetDetailsPane/EndTimeBox.text = ""

func _on_open_startgg_link_button_pressed() -> void:
	OS.shell_open(startgg_link)

func _on_open_video_link_button_pressed() -> void:
	OS.shell_open(video_url)

func _on_open_existing_button_pressed() -> void:
	if(DirAccess.dir_exists_absolute(project_parent_path)):
		$Background/InitializationWindow/OpenExistingButton/FileDialog.current_path = project_parent_path
	$Background/InitializationWindow/OpenExistingButton/FileDialog.show()
