extends Node2D
class_name Obstacle

@onready var level : LevelClass = _set_level()
@onready var grid : TileMap = _set_grid()
@onready var sprite : Sprite2D = _onready_sprite()

@export var blocking = true

func _set_level():
	return get_parent()

func _set_grid():
	for child in get_parent().get_children():
		if child is TileMap:
			return child
	return null

func _onready_sprite():
	for child in get_children():
		if child is Sprite2D:
			return child
