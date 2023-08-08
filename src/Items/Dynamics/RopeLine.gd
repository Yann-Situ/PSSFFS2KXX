#tool
extends Path2D
class_name RopeLine
# @icon("res://assets/art/icons/ropelineline.png")

@export var invert_line_direction : bool = false
@onready var segment_collision_offset = Vector2(0.0,0.0)
@export_group("Character parameters", "character_")
@export var character_offset : Vector2 = Vector2(0.0, 0.0)
@export var character_cant_get_in_again_delay : float = 0.2#s

const tolerance_annoying_case = 4.0

var init_point = Vector2.ZERO
var final_point = Vector2.ZERO

var collision_segments = []

var paths_to_free = {}
var path_follows = {}
var position_offsets = {}
var released_bodies = {}

func _update_points():
	#ropeline_dir = (final_point-init_point).normalized()
	$Line2D.clear_points()
	var p0
	var p1
	var w = Vector2(0.0, 0.5 * $Line2D.width)
	for i in range(curve.get_point_count()-1):
		if invert_line_direction:
			p0 = curve.get_point_position(curve.get_point_count()-i-1)
			p1 = curve.get_point_position(curve.get_point_count()-i-2)
		else :
			p0 = curve.get_point_position(i)
			p1 = curve.get_point_position(i+1)
		$Line2D.add_point(p0+w)
		$Line2D.add_point(p1+w)

		var new_segment = CollisionShape2D.new()
		new_segment.shape = SegmentShape2D.new()
		new_segment.shape.set_a(p0+segment_collision_offset)
		new_segment.shape.set_b(p1+segment_collision_offset)
		#print("segment : "+str(p0+segment_collision_offset)+" - "+str(p1+segment_collision_offset))
		collision_segments.push_back(new_segment)
		$Area2D.add_child(new_segment)

###############################################################################

func _ready():
	self.z_index = Global.z_indices["foreground_1"]
	add_to_group("characterholders")
	if curve.get_point_count() >= 2:
		final_point = curve.get_point_position(curve.get_point_count()-1)
	else :
		push_error("Not enough points in the curve!")
	_update_points()

func is_in(a, b, c, tolerance = 0.0):
	return a >= b+tolerance and a < c-tolerance

func _on_Area_body_exited(body : Node2D):
	if !body.is_in_group("characters") :
		return 1
	if body.is_hold(): # already hold by a character_holder
		return 1
	if body.has_node("Actions/Hang") and !body.S.can_hang:
		print_debug(body.name + "have a node Actions/Hang but cannot hang")
		return 1
	if path_follows.has(body):
		push_warning(body.name+" already in "+self.name)
		return 1
	if released_bodies.has(body):
		print_debug(body.name+" just got out from "+self.name)
		return 1

	var bi = body.global_position-global_position-init_point
	# here we compute the local point and the ropeline local tangent direction
	var closest_progress = curve.get_closest_offset(bi)
	if not is_in(closest_progress, 0.0, curve.get_baked_length(),0.5*curve.bake_interval):
			push_warning("ropeline limit edge case")# not a problem in practice
	var closest_point = curve.sample_baked(closest_progress-0.5*curve.bake_interval)
	var ropeline_dir = curve.sample_baked(closest_progress+0.5*curve.bake_interval)-closest_point
	if invert_line_direction:
		ropeline_dir = -ropeline_dir

	if ropeline_dir.cross(body.S.velocity) >= 0.0 :
		# add it to the ropeline
		var new_path_follow : PathFollow2D = PathFollow2D.new()
		new_path_follow.loop = false
		self.add_child(new_path_follow)

		new_path_follow.progress = closest_progress # approximate where the player is
		ropeline_dir = new_path_follow.transform.x

		path_follows[body] = new_path_follow
		position_offsets[body] = body.global_position-new_path_follow.global_position
		pickup_character(body)

################################################################################
# For `characterholders` group
func pickup_character(character : Node2D):
	character.get_in(self)
	print(character.name+" on "+self.name)
	if character.has_node("Actions/Hang"):
		character.get_node("Actions/Hang").move(0.01)

func free_character(character : Node2D):
	# called by character when getting out
	print(name+" free_character("+character.name+")")
	if character.has_node("Actions/Hang"):
		character.get_node("Actions/Hang").move_stop()
	remove_body(character)

func remove_body(body : Node2D):
	released_bodies[body] = character_cant_get_in_again_delay
	path_follows[body].call_deferred("queue_free")
	path_follows.erase(body)
	position_offsets.erase(body)

func move_character(character : Node2D, linear_velocity : Vector2, \
	delta : float) -> Vector2:
	assert(path_follows.has(character))
	var path_follow = path_follows[character]
	var position_offset = position_offsets[character]
	var ropeline_dir = path_follow.transform.x
	var new_velocity_length = linear_velocity.dot(ropeline_dir)

	path_follow.progress += new_velocity_length * delta
	position_offset = lerp(position_offset, character_offset, 0.1)
	character.global_position = path_follow.global_position + position_offset
	position_offsets[character] = position_offset

	if path_follow.get_progress_ratio() >= 1.0 or \
		path_follow.get_progress_ratio() <= 0.0 or \
		(character.has_node("Actions/Hang") and !character.S.is_hanging) :
		character.get_out(character.global_position, new_velocity_length * ropeline_dir)
	return new_velocity_length * ropeline_dir

############################################################################
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for body in released_bodies.keys():
		released_bodies[body] -= delta
		if released_bodies[body] < 0.0:
			released_bodies.erase(body)
