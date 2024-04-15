extends Control

var window_size = Vector2(1920, 1080)

var test_level_template = preload("res://levels/TestLevel.tscn")
var current_level_template = test_level_template
var currently_restarting = false

func _ready():
	Global.Holder = self
	Global.request_next_level.connect(start_next_level)
	Global.request_level_restart.connect(restart_level)
	if Global.level_to_load != "":
		start_next_level(Global.level_to_load)
		Global.level_to_load = ""
		
	

func _unhandled_key_input(event):
	if event is InputEventKey:
		if event.is_pressed() and event.keycode == KEY_R:
			print("Rua!")
			restart_level()
		elif event.is_pressed() and event.keycode == KEY_ESCAPE:
			if $GameGUI/BookGUI.is_closed:
				back_to_title()


func back_to_title():
	Global.can_move_now = false
	$AnimationPlayer.play("black_enter")
	await $AnimationPlayer.animation_finished
	Global.can_move_now = true
	get_tree().change_scene_to_file("res://TitleScreen.tscn")


func restart_level():
	if currently_restarting:
		push_warning("try to restart twice???")
		return
	currently_restarting = true
	$GameGUI/BookGUI.page_close()
	$AnimationPlayer.play("black_enter")
	
	await $AnimationPlayer.animation_finished
	
	$SubViewportContainer/SubViewport.get_child(0).queue_free()
	var restarted_level =current_level_template.instantiate()
	$SubViewportContainer/SubViewport.add_child(restarted_level)
	
	# Reset Globals
	Global.vacant_summon_slot = restarted_level.initial_vacant_summons
	Global.reset_flags()
	Global.level_reset.emit()
	
	$AnimationPlayer.play("black_exit")
	currently_restarting = false

func start_next_level(level_path):
	current_level_template = load(level_path)
	restart_level()


func play_summon():
	$AudioSummon.play()

func play_select():
	$AudioSelect.play()

func play_walk():
	$AudioWalk.play()
