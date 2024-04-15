extends Node2D
class_name Pushy

@onready var level : LevelClass = _set_level()
@onready var grid : TileMap = _set_grid()
@onready var sprite : Sprite2D = _onready_sprite()

@export var tag : String = ""

var playable = false
var selected = true : set = _set_selected, get=_get_selected

var is_moving = false

@export var strength : int = 3
@export var weight : int = 1

const STEPSIZE = 60

const DIRECTIONS = {
	"left": Vector2(-STEPSIZE, 0), 
	"right": Vector2(STEPSIZE, 0), 
	"up": Vector2(0, -STEPSIZE), 
	"down": Vector2(0, STEPSIZE)
}

enum PRET {FAIL, BLOCK, WALK, PUSH, CONSUME}


func try_and_move(direction : String) -> PRET:
	var pushing_weight = try_and_weigh(direction)
	if pushing_weight - weight <= strength:
		return just_move(direction)
	else:
		play_punch_animation(direction)
	return PRET.BLOCK

func just_move(direction : String) -> PRET:
	if direction not in DIRECTIONS:
		push_warning("[Pushy] Error Direction!!!!")
		return PRET.FAIL
	
	var move_delta = DIRECTIONS[direction]
	
	# Check if anything (in the tilemap) is blocking the way!!
	var target_grid_location = grid.local_to_map(grid.to_local(self.position + move_delta))
	var target_tile_data = grid.get_cell_tile_data(0, target_grid_location)
	if target_tile_data == null:
		# push_warning("[Pushy] try to move, but target cell is null???")
		pass
	elif target_tile_data.get_custom_data("mode"):
		# Cannot move to the target position. 
		return PRET.FAIL
	
	# Check if any objects are blocking the way. 
	var pushed_pushy : Pushy = level.get_pushy_by_position(target_grid_location)
	if pushed_pushy != null:
		# We have already checked pushable so... just move!
		var _push_ret = pushed_pushy.just_move(direction)
	
	# One last thing: Consider the touch. 
	var the_touchy : Touchy = level.get_touchy_by_position(target_grid_location)
	if the_touchy != null:
		the_touchy.on_touch(self)
	
	# Now, actually we can move!!!
	self.position += move_delta
	play_move_animation(move_delta)
	if pushed_pushy != null:
		return PRET.PUSH
	return PRET.WALK

func try_and_weigh(direction : String) -> int:
	if direction not in DIRECTIONS:
		push_warning("[Pushy] Error Direction!!!!")
		return 1919810
	var move_delta = DIRECTIONS[direction]
	
	# Check if anything (in the tilemap) is blocking the way!!
	var target_grid_location = grid.local_to_map(grid.to_local(self.position + move_delta))
	var target_tile_data = grid.get_cell_tile_data(0, target_grid_location)
	if target_tile_data == null:
		pass
	elif target_tile_data.get_custom_data("mode"):
		# Cannot move to the target position. 
		return 114514 + weight
	
	# Check if any objects are blocking the way. 
	var pushed_obstacle : Obstacle = level.get_obstacle_by_position(target_grid_location)
	if pushed_obstacle != null:
		if pushed_obstacle.blocking:
			return 10086
	
	var pushed_pushy : Pushy = level.get_pushy_by_position(target_grid_location)
	if pushed_pushy != null:
		var others_weight = pushed_pushy.try_and_weigh(direction)
		return weight + others_weight

	return weight

func play_move_animation(move_delta : Vector2):
	# Assuming the thing has already moved. 
	if sprite == null:
		return
	sprite.position = sprite.position - move_delta
	var tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(sprite, "position", Vector2(0, 0), 0.16)
	tween.tween_callback(self._play_move_animation_callback)
	Global.still_moving_thing += 1
	is_moving = true

func play_punch_animation(direction):
	if sprite == null:
		return
	var tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	tween.tween_method(func(t): _punch_animation_update(direction, t), 0.0, 1.0, 0.2)
	tween.tween_callback(self._play_move_animation_callback)
	Global.still_moving_thing += 1
	is_moving = true

func die():
	"""abstract function; make player die, etc. """


func _punch_animation_update(direction, t : float):
	if direction not in DIRECTIONS:
		push_warning("[Error] Direction doesn't exist!!")
		return false
	match direction:
		"up":
			sprite.position = _cubic_bezier(Vector2(0, 0), Vector2(0, -10), Vector2(0, 10), Vector2(0, 0), t)
		"down":
			sprite.position = _cubic_bezier(Vector2(0, 0), Vector2(0, 10), Vector2(0, -10), Vector2(0, 0), t)
		"left":
			sprite.position = _cubic_bezier(Vector2(0, 0), Vector2(-10, 0), Vector2(10, 0), Vector2(0, 0), t)
		"right":
			sprite.position = _cubic_bezier(Vector2(0, 0), Vector2(-10, 0), Vector2(-10, 0), Vector2(0, 0), t)

func _play_move_animation_callback():
	Global.still_moving_thing -= 1
	is_moving = false

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

func _set_selected(s):
	if not playable:
		selected = false
		return
	if not selected and s:
		level.selected_pushy = self
	selected = s

func _get_selected():
	return selected

func _cubic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var q2 = p2.lerp(p3, t)

	var r0 = q0.lerp(q1, t)
	var r1 = q1.lerp(q2, t)

	var s = r0.lerp(r1, t)
	return s
