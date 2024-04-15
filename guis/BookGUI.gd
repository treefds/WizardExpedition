extends Control



var list_of_pages = []

var current_page : int = 0
var is_closed = true
# Called when the node enters the scene tree for the first time.
func _ready():
	list_of_pages.append($Page1)
	list_of_pages.append($Page2)
	list_of_pages.append($Page3)
	list_of_pages.append($Page4)
	$LeftButton.button_up.connect(page_left)
	$RightButton.button_up.connect(page_right)
	$ExitButton.button_up.connect(page_close)

func page_left():
	current_page = max(0, current_page - 1)
	for page in list_of_pages:
		page.visible = false
	list_of_pages[current_page].visible = true

func page_right():
	current_page = min(len(list_of_pages) - 1, current_page + 1)
	for page in list_of_pages:
		page.visible = false
	list_of_pages[current_page].visible = true

func page_close():
	position = Vector2(2000, 2000)
	is_closed = true
	pass

func page_open():
	position = Vector2(0, 0)
	is_closed = false
