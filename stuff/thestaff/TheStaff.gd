extends Touchy

const diag_lines = preload("res://resources/dialogs/dialog_obtain_staff.dialogue")

func on_touch(toucher : Pushy):
	if toucher is Wizard:
		Global.obtained_great_staff.emit()
		Global.in_great_staff_cutscene = true
		Global.can_move_now = false
		
		var tween = get_tree().create_tween().bind_node(self)
		tween.tween_property(sprite, "position", sprite.position - Vector2(0, 45), 1.2)
		tween.set_trans(Tween.TRANS_QUAD)

		
		var diag = DialogueManager.show_dialogue_balloon(diag_lines)
		await DialogueManager.dialogue_ended
		Global.in_great_staff_cutscene = false
		Global.can_move_now = true
		Global.vacant_summon_slot = 1
		Global.summon_retrieved.emit()
		Global.set_level_title_and_tip.emit("Summoning!!!", "Press [R] to restart\nClick Book on the Right for more help")
		Global.game_progress = 3
		diag.queue_free()
		queue_free()
