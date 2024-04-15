extends Control

func _ready():
	for child in self.get_children():
		if child is TextureButton:
			child.button_clicked.connect(goto_level)


func goto_level(level_file_path):
	Global.level_to_load = level_file_path
	get_tree().change_scene_to_file("res://SceneHolder.tscn")
