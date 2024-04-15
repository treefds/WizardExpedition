extends TextureButton


@export_file var level_to_load : String

@export var minimum_progress : int = 100000

func _ready():
	if Global.game_progress < minimum_progress:
		disabled = true
	self.button_down.connect(_on_button_down)


signal button_clicked
func _on_button_down():
	button_clicked.emit(level_to_load)
	
