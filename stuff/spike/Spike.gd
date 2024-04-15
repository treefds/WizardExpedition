extends Touchy

func on_touch(toucher):
	if toucher is Wizard:
		toucher.die()
		
