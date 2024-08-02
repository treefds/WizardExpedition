extends Control


func _ready():
	$ButtonCore.toggled.connect(_on_button_core_update)
	Global.just_summoned.connect(_reset_button_core)
	Global.summon_retrieved.connect(_reset_button_core)
	Global.level_reset.connect(_reset_button_core)
	Global.set_level_title_and_tip.connect(_set_tip)
	Global.game_progress_updated.connect(_on_game_progress_updated)
	$BookButton.button_up.connect($BookGUI.page_open)
	if Global.game_progress < 3:
		$BookButton.visible = false


func _on_button_core_update(toggle):
	Global.is_summoning = toggle

func _reset_button_core():
	$ButtonCore.set_pressed_no_signal(false)
	if Global.vacant_summon_slot == 0:
		$ButtonCore.disabled = true
	else:
		$ButtonCore.disabled = false

func _unhandled_key_input(event):
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and event.is_pressed() and not $ButtonCore.disabled:
			$ButtonCore.button_pressed = not $ButtonCore.button_pressed
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_Z and event.is_pressed():
			Global.try_to_run_dialog("regret", load("res://resources/dialogs/dialog_regret.dialogue"))

func _set_tip(title : String, tip : String):
	$TitleLabel.text = title
	$TipLabel.text = tip

func _on_game_progress_updated():
	if Global.game_progress >= 3:
		$BookButton.visible = true
