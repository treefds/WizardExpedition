extends Touchy
class_name RaddishButton

@export var button_tag : String = ""

func _process(delta):
	if level.get_pushy_by_position(level.world_to_map(position)) != null:
		Global.red_button_flags[button_tag] = true
		self.sprite.frame = 1
	else:
		Global.red_button_flags[button_tag] = false
		self.sprite.frame = 0
		
		
