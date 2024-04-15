extends Touchy

const diag_lines = preload("res://resources/dialogs/dialog_obtain_powerup.dialogue")

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
		if Global.vacant_summon_slot == 1:
			Global.vacant_summon_slot = 2
		elif Global.vacant_summon_slot == 0:
			Global.vacant_summon_slot = 1
		Global.game_progress = 141
		Global.summon_retrieved.emit()
		# Global.set_level_title_and_tip.emit("Summoning", "Press [SPACE], then Left-click to summon\nPress [R] to restart")
		diag.queue_free()
		queue_free()
