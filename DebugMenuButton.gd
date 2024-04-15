extends Button


@export_file var level_to_load : String



func _ready():
	button_down.connect(_on_button_down)


signal button_clicked
func _on_button_down():
	button_clicked.emit(level_to_load)
	
