extends Touchy


@export_file var diag_file
@export var dialog_flag = ""
var diag_lines

func _ready():
	visible = false
	diag_lines = load(diag_file)
	

func on_touch(toucher : Pushy):
	if toucher is Wizard:
		if dialog_flag not in Global.dialog_flags:
			Global.dialog_flags[dialog_flag] = true
			run_dialog()
			
			
func run_dialog():
	var diag = DialogueManager.show_dialogue_balloon(diag_lines)
	await DialogueManager.dialogue_ended
	diag.queue_free()

		
	
