extends Pushy

var age = 0

func _ready():
	tag = "flowerpot"
func _process(_delta):

	if tag == "pot":
		age += 1
		if age == 1:
			tag = "flowerpot"
		else:
			tag = "deadpot"
	$Sprite2D.frame = age
