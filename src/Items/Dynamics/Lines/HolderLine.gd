#tool
# @icon("res://assets/art/icons/ropeline.png")
extends Path2D
class_name HolderLine

@export var invert_line_direction : bool = false
@onready var segment_collision_offset = Vector2(0.0,0.0)
@export_group("Character parameters", "character_")
@export var character_offset : Vector2 = Vector2(0.0, 0.0)
@export var character_cant_get_in_again_delay : float = 0.2#s
@onready var character_holder : CharacterHolder = get_node("CharacterHolder")

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
	assert(character_holder != null)
	character_holder.getting_in.connect(_on_character_holder_getting_in)
	character_holder.getting_out.connect(_on_character_holder_getting_out)
	character_holder.processing_character.connect(_on_character_holder_processing_character)
	character_holder.physics_processing_character.connect(_on_character_holder_physics_processing_character)
	_update_points()

func is_in(a, b, c, tolerance = 0.0):
	return a >= b+tolerance and a < c-tolerance

func belong_handler_pickup(belong_handler : Area2D):
	if !belong_handler is BelongHandler :
		push_warning(belong_handler.name+" is not BelongHandler")
		return 1
	if path_follows.has(belong_handler):
		push_warning(belong_handler.name+" already in "+self.name)
		return 1
	if released_bodies.has(belong_handler):
		print_debug(belong_handler.name+" just got out from "+self.name)
		return 1
	var character : Node2D = belong_handler.character
	if character == null:
		push_warning("belong_handler.character is null")
		return 1

	var velocity = Vector2.ZERO
	if "velocity" in character:
		velocity = character.velocity
	var bi = character.global_position-global_position-init_point
	# here we compute the local point and the ropeline local tangent direction
	var closest_progress = curve.get_closest_offset(bi)
	if not is_in(closest_progress, 0.0, curve.get_baked_length(),0.5*curve.bake_interval):
		push_warning("holderline limit edge case")# not a problem in practice
	var closest_point = curve.sample_baked(closest_progress-0.5*curve.bake_interval)
	var ropeline_dir = curve.sample_baked(closest_progress+0.5*curve.bake_interval)-closest_point
	if invert_line_direction:
		ropeline_dir = -ropeline_dir

	if ropeline_dir.cross(velocity) >= 0.0 :
		if belong_handler.get_in(character_holder):
			# add it to the ropeline
			var new_path_follow : PathFollow2D = PathFollow2D.new()
			new_path_follow.loop = false
			self.add_child(new_path_follow)

			new_path_follow.progress = closest_progress # approximate where the player is
			ropeline_dir = new_path_follow.transform.x

			path_follows[belong_handler] = new_path_follow
			position_offsets[belong_handler] = character.global_position-new_path_follow.global_position
		else:
			print(belong_handler.name+" did not get in "+self.name)


################################################################################
## For `characterholders` group
## functions are connected to character_holder signals in _ready()

func _on_character_holder_getting_in(belong_handler : BelongHandler):
	print(belong_handler.character.name+" on "+self.name)

func _on_character_holder_getting_out(belong_handler : BelongHandler):
	#when getting out
	print(belong_handler.character.name+" out "+self.name)
	released_bodies[belong_handler] = character_cant_get_in_again_delay
	path_follows[belong_handler].queue_free()
	path_follows.erase(belong_handler)
	position_offsets.erase(belong_handler)

## should update position and velocity (like move and slide)
func _on_character_holder_physics_processing_character(belong_handler : BelongHandler, delta):
	assert(path_follows.has(belong_handler) and "velocity" in belong_handler.character)
	var path_follow = path_follows[belong_handler]
	var position_offset = position_offsets[belong_handler]
	var ropeline_dir = path_follow.transform.x
	var character = belong_handler.character
	var new_velocity_length = character.velocity.dot(ropeline_dir)

	path_follow.progress += new_velocity_length * delta
	position_offset = lerp(position_offset, character_offset, 0.1)

	character.global_position = path_follow.global_position + position_offset
	character.set_velocity(new_velocity_length * ropeline_dir)
	position_offsets[belong_handler] = position_offset

	if path_follow.get_progress_ratio() >= 1.0 or path_follow.get_progress_ratio() <= 0.0 :
		belong_handler.get_out()

func _on_character_holder_processing_character(belong_handler : BelongHandler, delta):
	pass # Replace with function body.

############################################################################
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for body in released_bodies.keys():
		released_bodies[body] -= delta
		if released_bodies[body] < 0.0:
			released_bodies.erase(body)
