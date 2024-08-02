extends Pushy
class_name Wizard

var dead = false

func _ready():
	playable = true
	strength = 2
	selected = true
	
	$AnimationPlayer.play("idle")

var anim_timer = 0

func _process(delta):
	$SummoningParticle.visible = Global.is_summoning
	if Global.is_summoning:
		$Sprite2D.frame = 4
	anim_timer += delta
	$Sprite2D/SelectIcon.position = _cubic_bezier(Vector2(0, -40), Vector2(0, -50), Vector2(0, -30), Vector2(0, -40), anim_timer - int(anim_timer))
	$Sprite2D/SelectIcon.visible = selected
	$Sprite2D/SelectIcon.frame = Global.vacant_summon_slot
	
	if not is_moving and dead:
		sprite.frame = 6
	
	if not is_moving and Global.in_great_staff_cutscene:
		sprite.frame = 5


func _unhandled_input(event):
	if not selected:
		return
	if not Global.can_move_now or is_moving or Global.is_summoning or dead:
		return
	if event is InputEvent:
		if event.is_action_pressed("move_up"):
			wizard_try_and_move("up")
			$Sprite2D.frame = 1
		elif event.is_action_pressed("move_down"):
			wizard_try_and_move("down")
			$Sprite2D.frame = 0
		elif event.is_action_pressed("move_left"):
			wizard_try_and_move("left")
			$Sprite2D.frame = 2
		elif event.is_action_pressed("move_right"):
			wizard_try_and_move("right")
			$Sprite2D.frame = 3

			
func wizard_try_and_move(direction: String) -> PRET:
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
		play_punch_animation(direction)
		return PRET.FAIL
	
	# Check if the object is k
	var pushed_pushy : Pushy = level.get_pushy_by_position(target_grid_location)
	if pushed_pushy != null and pushed_pushy is Pushy and pushed_pushy.playable:
		Global.Holder.play_summon()
		if pushed_pushy is StoneGolem:
			var bigrock = load("res://stuff/rock/Bigrock.tscn").instantiate()
			bigrock.position = pushed_pushy.position
			level.add_child(bigrock)
			pushed_pushy.queue_free()
			Global.vacant_summon_slot += 2
			play_punch_animation(direction)
			level.create_superglow(level.world_to_map(bigrock.position))
			Global.summon_retrieved.emit()
			
			return PRET.CONSUME
		else:
			pushed_pushy.queue_free()
			Global.vacant_summon_slot += 1
			self.position += move_delta
			play_move_animation(move_delta)
			level.create_superglow(level.world_to_map(position))
			
			Global.summon_retrieved.emit()
			
			return PRET.CONSUME
	
	var touched_touchy : Touchy = level.get_touchy_by_position(target_grid_location)
	
	var pushing_weight = try_and_weigh(direction)
	if pushing_weight - weight <= strength:
		var moved_return = just_move(direction)
		if touched_touchy != null:
			touched_touchy.on_touch(self)
		$AudioStreamPlayer.play()
		return moved_return
	else:
		$AudioStreamPlayerPush.play()
		play_punch_animation(direction)
	return PRET.BLOCK


func die():
	if not dead:
		dead = true
		var timer = get_tree().create_timer(1.2)
		await timer.timeout
		Global.request_level_restart.emit()

