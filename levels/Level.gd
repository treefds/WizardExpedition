extends Node2D
class_name LevelClass

@onready var grid : TileMap = _set_grid()

const GrassGolemT = preload("res://summons/grass_golem/GrassGolem.tscn")
const StoneGolemT = preload("res://summons/stone_golem/StoneGolem.tscn")

@onready var wizard : Pushy = _set_wizard()
@export var initial_vacant_summons : int = 1
@export_file var next_level_path

@export_multiline var level_tip : String
@export var level_title : String

@export var level_number = 0

func _ready():
	Global.summoning_updated.connect(on_summoning_updated)
	Global.set_level_title_and_tip.emit(level_title, level_tip)
	
	Global.game_progress = max(level_number, Global.game_progress)

func _unhandled_input(event):
	if event is InputEventMouse:
		if event.is_pressed() and event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			handle_mouseclick(event)


func handle_mouseclick(event):
	if not Global.can_move_now:
		return 0
	var mouse_grid_position = grid.local_to_map(get_local_mouse_position())
	var pushy = get_pushy_by_position(mouse_grid_position)
	
	if pushy != null and pushy.playable and not Global.is_summoning:
		pushy.selected = true
		return 1

	if Global.is_summoning and pushy == null:
		var to_summon = check_summon_eligible(mouse_grid_position, Global.vacant_summon_slot)
		if to_summon:
			var summoned = try_summon(mouse_grid_position, to_summon)
			summoned.selected = true
			Global.is_summoning = false
			Global.vacant_summon_slot -= 1 if to_summon == 'A' else 2
			Global.just_summoned.emit()

func get_vacancy_by_position(pos : Vector2i) -> bool:
	"""If some pushy or touchy occupied this tile, return false"""
	for child in get_children():
		if child is Pushy or child is Touchy or child is Obstacle:
			if grid.local_to_map(grid.to_local(child.position)) == pos:
				return false
	return true

func get_obstacle_by_position(pos : Vector2i) -> Obstacle:
	"""If some pushy or touchy occupied this tile, return false"""
	for child in get_children():
		if child is Obstacle:
			if grid.local_to_map(grid.to_local(child.position)) == pos:
				return child
	return null

func get_pushy_by_position(pos: Vector2i) -> Pushy:
	"""Get every pushy that is direct children of Level. """
	for child in get_children():
		if child is Pushy:
			if grid.local_to_map(grid.to_local(child.position)) == pos:
				return child
	return null

func get_touchy_by_position(pos: Vector2i) -> Touchy:
	"""Get every touchy that is direct children of Level. """
	for child in get_children():
		if child is Touchy:
			if grid.local_to_map(grid.to_local(child.position)) == pos:
				return child
	return null


var selected_pushy : Pushy = null : set = _set_selected_pushy
func _set_selected_pushy(pushy):
	if pushy == selected_pushy:
		return
	
	Global.Holder.play_select()
	selected_pushy = null
	if pushy == null:
		return
	for child in self.get_children():
		if child is Pushy and child != pushy:
			child.selected = false


func check_summon_eligible(pos : Vector2i, points : int):
	for mob in ["B", "A"]:
		match mob:
			"A":
				if (grid.get_cell_tile_data(0, pos) == null and
					get_vacancy_by_position(pos) and
					grid.get_cell_tile_data(1, pos) != null and
					grid.get_cell_tile_data(1, pos).get_custom_data("meta") == "grass" and
					(pos - world_to_map(wizard.position)).length() <= 3.2):
					return "A"
				var stone_up = get_pushy_by_position(pos + Vector2i(0, -1))
				var stone_down = get_pushy_by_position(pos + Vector2i(0, 1))
				var stone_left = get_pushy_by_position(pos + Vector2i(-1, 0))
				var stone_right = get_pushy_by_position(pos + Vector2i(1, 0))
				if (((stone_up and stone_up.tag == "flowerpot") or 
					(stone_down and stone_down.tag == "flowerpot") or
					(stone_left and stone_left.tag == "flowerpot") or
					(stone_right and stone_right.tag == "flowerpot")) and
					(grid.get_cell_tile_data(0, pos) == null and
					get_vacancy_by_position(pos) and
					grid.get_cell_tile_data(1, pos) != null and 
					(pos - world_to_map(wizard.position)).length() <= 3.2)):
					return "A"
			"B":
				if Global.vacant_summon_slot >= 2:
					var stone_up = get_pushy_by_position(pos + Vector2i(0, -1))
					var stone_down = get_pushy_by_position(pos + Vector2i(0, 1))
					var stone_left = get_pushy_by_position(pos + Vector2i(-1, 0))
					var stone_right = get_pushy_by_position(pos + Vector2i(1, 0))
					var ok_up = stone_up != null and stone_up.tag == "smallrock"
					var ok_down = stone_down != null and stone_down.tag == "smallrock"
					var ok_left = stone_left != null and stone_left.tag == "smallrock"
					var ok_right = stone_right != null and stone_right.tag == "smallrock"
					if (get_vacancy_by_position(pos) and 
						((ok_up and ok_down) or (ok_left and ok_right))
						and (pos - world_to_map(wizard.position)).length() <= 3.2):
						return "B"
	
	return null

func try_summon(pos : Vector2i, mob : String) -> Pushy:
	Global.Holder.play_summon()
	match mob:
		"A":
			var new_golem = GrassGolemT.instantiate()
			self.add_child(new_golem)
			new_golem.position = grid.map_to_local(pos)
			if grid.get_cell_tile_data(1, pos).get_custom_data("meta") == "grass":
				grid.set_cell(1, pos, grid.get_cell_source_id(1, pos), grid.get_cell_atlas_coords(1, pos) - Vector2i(1, 0))
			else:
				var stone_up = get_pushy_by_position(pos + Vector2i(0, -1))
				var stone_down = get_pushy_by_position(pos + Vector2i(0, 1))
				var stone_left = get_pushy_by_position(pos + Vector2i(-1, 0))
				var stone_right = get_pushy_by_position(pos + Vector2i(1, 0))
				if stone_up: stone_up.tag = "pot"
				if stone_left: stone_left.tag = "pot"
				if stone_down: stone_down.tag = "pot"
				if stone_right: stone_right.tag = "pot"
			# Make effects
			create_superglow(pos)
			return new_golem
		"B":
			var new_golem = StoneGolemT.instantiate()
			self.add_child(new_golem)
			new_golem.position = grid.map_to_local(pos)
		
			var stone_up = get_pushy_by_position(pos + Vector2i(0, -1))
			var stone_down = get_pushy_by_position(pos + Vector2i(0, 1))
			var stone_left = get_pushy_by_position(pos + Vector2i(-1, 0))
			var stone_right = get_pushy_by_position(pos + Vector2i(1, 0))
			var ok_up = stone_up != null and stone_up.tag == "smallrock"
			var ok_down = stone_down != null and stone_down.tag == "smallrock"
			var ok_left = stone_left != null and stone_left.tag == "smallrock"
			var ok_right = stone_right != null and stone_right.tag == "smallrock"
			
			if (ok_up and ok_down):
				stone_up.queue_free()
				stone_down.queue_free()
				create_superglow(pos)
				create_superglow(pos - Vector2i(0, 1))
				create_superglow(pos + Vector2i(0, 1))
			elif (ok_left and ok_right):
				stone_left.queue_free()
				stone_right.queue_free()
				create_superglow(pos)
				create_superglow(pos + Vector2i(1, 0))
				create_superglow(pos + Vector2i(-1, 0))
			else:
				push_error("Try to summon Stone Golem but material isn't here")
			return new_golem
	
	return null	

const effect_t = preload("res://shaders/SummoningParticle.tscn")
const summon_t = preload("res://shaders/SummonSuperglow.tscn")

func create_superglow(pos):
	var summon_effect = summon_t.instantiate()
	self.grid.add_child(summon_effect)
	summon_effect.global_position = map_to_world(pos)

func on_summoning_updated(is_summoning):
	if is_summoning:
		make_summoning_effects(Global.mob_to_summon)
	else:
		clear_summoning_effects()

func make_summoning_effects(mob : String):
	var wizard_pos = world_to_map(wizard.position)
	for y in range(-3, 4):
		for x in range(-3, 4):
			var summon_tag = check_summon_eligible(wizard_pos + Vector2i(x, y), Global.vacant_summon_slot)
			if summon_tag != null:
				var new_particle = effect_t.instantiate()
				new_particle.add_to_group("SummonEffect")
				self.add_child(new_particle)
				# Change color
				if summon_tag == "A":
					new_particle.color = Color(0.3, 1., 0.6, 1.)
				elif summon_tag == "B":
					new_particle.color = Color(1., 1., 0.4, 1.)
				new_particle.position = map_to_world(wizard_pos + Vector2i(x, y))

func clear_summoning_effects():
	for child in self.get_children():
		if child.is_in_group("SummonEffect"):
			child.queue_free()
			



func _set_grid():
	for child in get_children():
		if child is TileMap:
			return child
	return null

func _set_wizard():
	for child in get_children():
		if child is Wizard:
			return child
	return null

func world_to_map(pos : Vector2) -> Vector2i:
	return grid.local_to_map(grid.to_local(pos))

func map_to_world(pos : Vector2i) -> Vector2:
	return grid.to_global(grid.map_to_local(pos))
