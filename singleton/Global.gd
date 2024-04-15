extends Node


var game_progress = 0 : set = _set_game_progress
signal game_progress_updated
func _set_game_progress(v):
	if v != game_progress:
		game_progress = v
		game_progress_updated.emit()


var dialog_flags = Dictionary()

# Singletons
var Holder = null

# Movement flags
var still_moving_thing = 0
var can_move_now = true

# Summon falgs
var vacant_summon_slot = 1
var is_summoning = false : set = _set_summoning
var mob_to_summon = "A"
func _set_summoning(v):
	if is_summoning != v:
		is_summoning = v
		summoning_updated.emit(v)

signal just_summoned
signal summon_retrieved
signal summoning_updated
signal request_level_restart

# Level resetting
signal level_reset
signal request_next_level
signal set_level_title_and_tip
var level_to_load : String = ""

# Cutscene
signal obtained_great_staff
var in_great_staff_cutscene = false

# Button props
var red_button_pressed : bool = false
var red_button_flags = Dictionary()

func reset_flags():
	red_button_pressed = false
	red_button_flags = Dictionary()


func _process(_delta):
	# Tag Maintenance
	red_button_pressed = true
	for tag in red_button_flags:
		if red_button_flags[tag] == false:
			red_button_pressed = false

func try_to_run_dialog(dial_flag, diag_lines):
	if dial_flag not in Global.dialog_flags:
		Global.dialog_flags[dial_flag] = true
		var diag = DialogueManager.show_dialogue_balloon(diag_lines)
		await DialogueManager.dialogue_ended
		diag.queue_free()


func _ready():
	load_game()
	game_progress_updated.connect(save_game)
	

func save_game():
	var save_dict = {
		"game_progress": game_progress, 
		"dialog_flags": dialog_flags
	}
	var saver = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	print("Saved game")
	saver.store_line(JSON.stringify(save_dict))

func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return false
	var loader = FileAccess.open("user://savegame.save", FileAccess.READ)
	var json_string = loader.get_line()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	print("Load game: ", parse_result, ' ', json_string)
	if not parse_result == OK:
		push_error("Error parsing game save")
		return false
	var read_data = json.get_data()
	game_progress = read_data["game_progress"]
	dialog_flags = read_data["dialog_flags"]
	return true
