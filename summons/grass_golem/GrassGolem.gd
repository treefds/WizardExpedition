extends Pushy

var remaining_push = 3

const sprite_tired = preload("res://summons/grass_golem/grass_golem_tired.png")
const sprite_sleepy = preload("res://summons/grass_golem/grass_golem_sleepy.png")

var anim_timer = 0.0
func _ready():
	playable = true
	selected = false
	strength = 1
	$AnimationPlayer.play("idle")

func _process(delta):
	anim_timer += delta
	$Sprite2D/SelectIcon.position = _cubic_bezier(Vector2(0, -40), Vector2(0, -50), Vector2(0, -30), Vector2(0, -40), anim_timer - int(anim_timer))
	$Sprite2D/SelectIcon.visible = selected

func _unhandled_input(event):	
	if not selected:
		return
	if not Global.can_move_now or is_moving or remaining_push == 0 or Global.is_summoning:
		return
	if event is InputEvent:
		var success
		if event.is_action_pressed("move_up"):
			success = try_and_move("up")
		elif event.is_action_pressed("move_down"):
			success = try_and_move("down")
		elif event.is_action_pressed("move_left"):
			success = try_and_move("left")
		elif event.is_action_pressed("move_right"):
			success = try_and_move("right")
		Global.Holder.play_walk()
		if success == PRET.PUSH:
			grow_tired()

func grow_tired():
	remaining_push -= 1
	if remaining_push == 1:
		$Sprite2D.texture = sprite_tired
		$AnimationPlayer.play("tired")
	elif remaining_push <= 0:
		$Sprite2D.texture = sprite_sleepy
		$AnimationPlayer.play("sleepy")
		$SleepyParticle.emitting = true
		Global.try_to_run_dialog("sleepy", load("res://resources/dialogs/dialog_sleepy.dialogue"))
