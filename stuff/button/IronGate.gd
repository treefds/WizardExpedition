extends Obstacle

func _ready():
	if not blocking:
		sprite.frame = 2

func _process(delta):
	if Global.red_button_pressed and blocking:
		$AnimationPlayer.play("open")
		self.blocking = false
	elif not Global.red_button_pressed and not blocking:
		var the_pushy = level.get_pushy_by_position(level.world_to_map(position)) 
		if the_pushy == null:
			$AnimationPlayer.play("close")
			self.blocking = true
		elif the_pushy is Wizard:
			the_pushy.die()
			$AnimationPlayer.play("close")
			self.blocking = true
