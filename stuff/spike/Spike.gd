extends Touchy

func on_touch(toucher):
	if toucher is Wizard:
		toucher.die()

func _process(_delta):
	if round(level.wizard.position) == round(self.position):
		level.wizard.die()
