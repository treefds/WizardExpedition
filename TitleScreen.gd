extends Control

const level_panel = preload("res://guis/SelectLevel.tscn")

func _ready():
	$AnimationPlayer.play("black_exit")

func _unhandled_key_input(event):
	if event.is_pressed() and event.keycode == KEY_SPACE:
		if Global.game_progress == 0:
			print("Start New Game")
			$AnimationPlayer.play("black_enter")
			await $AnimationPlayer.animation_finished
			
			Global.level_to_load = "res://levels/level0a/Level0a.tscn"
			get_tree().change_scene_to_file("res://SceneHolder.tscn")
		else:
			print("Continue game")
			$PressSpaceToStart.visible = false
			var panel = level_panel.instantiate()
			self.add_child(panel)
			
	
