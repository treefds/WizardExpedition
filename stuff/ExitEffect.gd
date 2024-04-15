extends Touchy


# Called when the node enters the scene tree for the first time.

func on_touch(toucher : Pushy):
	if toucher is Wizard and level.next_level_path != null:
		Global.request_next_level.emit(level.next_level_path)
	else:
		push_warning("Next Level not set yet!!")
