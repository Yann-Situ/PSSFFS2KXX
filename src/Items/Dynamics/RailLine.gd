#tool
extends Path2D
class_name RailLine, "res://assets/art/icons/railline.png"

export (bool) var invert_line_direction = false
export (float) var character_position_offset = -32.0
export (float) var character_position_entrance_tolerance = -16.0
export (float) var character_collision_offset = -52.0
export (float) var cant_get_in_again_timer = 0.2#s

onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") # pix/s²
onready var character_offset = Vector2(0.0,character_position_offset)
onready var collision_offset = Vector2(0.0,0.0)
var tolerance_annoying_case = 4.0

var _particle = preload("res://src/Effects/RideParticles.tscn")

var init_point = Vector2.ZERO
var final_point = Vector2.ZERO

var collision_segments = []

var inside_bodies = []
var path_follows = []
var linear_velocities = []
var position_offsets = []

var real_character_offset = Vector2.ZERO

var paths_to_free = {}
var released_bodies = {}

func _update_points():
	#rail_dir = (final_point-init_point).normalized()
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
		new_segment.shape.set_a(p0+collision_offset)
		new_segment.shape.set_b(p1+collision_offset)
		#print("segment : "+str(p0+collision_offset)+" - "+str(p1+collision_offset))
		collision_segments.push_back(new_segment)
		$Area.add_child(new_segment)

###############################################################################

func _ready():
	self.z_index = Global.z_indices["foreground_1"]
	add_to_group("characterholders")
	if curve.get_point_count() >= 2:
		#print(self.name + " setcurve")
		final_point = curve.get_point_position(curve.get_point_count()-1)
		#print(final_point)
	else :
		print(self.name+" Error: not enough points in the curve!")
	_update_points()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):

	var j = 0 # int because we're deleting nodes in a list we're browsing
	for i in range(inside_bodies.size()):
		var body = inside_bodies[i-j]
		var path_follow = path_follows[i-j]
		var velocity = linear_velocities[i-j]
		var position_offset = position_offsets[i-j]
		var rail_dir = path_follow.transform.x
		# transform.x is the direction (vec2D) of the pathfollow
		velocity.y += gravity * delta
		velocity = velocity.dot(rail_dir) * rail_dir
		position_offset = lerp(position_offset, character_offset, 0.5)

		path_follow.offset += velocity.dot(rail_dir) * delta
		body.global_position = path_follow.global_position + position_offset
		body.S.velocity = velocity

		linear_velocities[i-j] = velocity
		position_offsets[i-j]  = position_offset
		if path_follow.get_unit_offset() == 1.0 or \
		   path_follow.get_unit_offset() == 0.0 or \
		   body.S.crouch_p :
#
#			body.enable_physics()
#			body.S.velocity = velocity
#			inside_bodies.remove(i-j)
#			paths_to_free.push_back(path_follows[i-j])
#			path_follows.remove(i-j)
#			linear_velocities.remove(i-j)
#			position_offsets.remove(i-j)
#
#			print(body.name+" quit "+self.name)
			body.get_out(body.global_position, velocity)
			j += 1 # because we deleted a node in the list we're browsing

			# the following code can result in wrong j and i values if there are
			# multiple character on trail...
			# A workaround would be to queue_free and stop emitting after the
			# for loop.
#			temp_particles.emitting = false
#			yield(get_tree().create_timer(temp_particles.lifetime), "timeout")
#			temp_path_follow.call_deferred("queue_free")

	# Ugly but it works :
	for p in paths_to_free.keys():
		paths_to_free[p] -= delta
		if paths_to_free[p] < 0.0:
			p.call_deferred("queue_free")
			paths_to_free.erase(p)
			
	for body in released_bodies.keys():
		released_bodies[body] -= delta
		if released_bodies[body] < 0.0:
			released_bodies.erase(body)
	
#	if not paths_to_free.empty():
#		var lifetime = paths_to_free[0].get_node("Particles").lifetime
#		print("release1 : "+str(released_bodies))
#		yield(get_tree().create_timer(min(lifetime,cant_get_in_again_timer)), "timeout")
#		print("release2 : "+str(released_bodies))
#		released_bodies = []
#		yield(get_tree().create_timer(abs(lifetime-cant_get_in_again_timer)), "timeout")
#		print("release3 : "+str(released_bodies))
#		for p in paths_to_free:
#			p.call_deferred("queue_free")
#		paths_to_free = []

func is_in(a, b, c, tolerance = 0.0):
	return a >= b+tolerance and a < c-tolerance

func _on_Area_body_entered(body):
	if not body.is_in_group("characters") :
		return

	var bi = body.global_position-global_position-init_point
	var closest_offset = curve.get_closest_offset(bi)
#	if not is_in(closest_offset, 0.0, curve.get_baked_length(),5.0):
#		print("annoying case")
	var closest_point = curve.interpolate_baked(closest_offset-0.001)
	var rail_dir = curve.interpolate_baked(closest_offset+0.001)-closest_point
	if rail_dir.x < 0.0:
		rail_dir = -rail_dir

	if (bi-closest_point).y <= character_position_entrance_tolerance or \
	   (rail_dir.cross(body.S.velocity) >= 0.0 and \
		is_in(closest_offset, 0.0, curve.get_baked_length(),tolerance_annoying_case)) :

		for b in inside_bodies:
			if b == body:
				print(body.name+" already in "+self.name)
				return 1

		for b in released_bodies.keys():
			if b == body:
				print(body.name+" just got out from "+self.name)
				return 1

		var new_path_follow : PathFollow2D = PathFollow2D.new()
		new_path_follow.loop = false
		var ride_particle : Particles2D = _particle.instance()
		ride_particle.name = "Particles"
		if invert_line_direction:
			ride_particle.process_material.direction.y = 1
		new_path_follow.add_child(ride_particle)
		self.add_child(new_path_follow)

		new_path_follow.offset = closest_offset # approximate where the player is
		rail_dir = new_path_follow.transform.x

		inside_bodies.push_back(body)
		path_follows.push_back(new_path_follow)
		body.S.velocity = body.S.velocity.dot(rail_dir) * rail_dir
		linear_velocities.push_back(body.S.velocity)
		position_offsets.push_back(body.global_position-new_path_follow.global_position)
		#body.disable_physics()
		pickup_character(body)

################################################################################
# For `characterholders` group
func pickup_character(character : Node):
	character.get_in(self)
	print(character.name+" on "+self.name)
	if character.has_node("Actions/Grind"):
		character.get_node("Actions/Grind").move(0.01)
	else :
		printerr(character.name + " doesn't have a node called Actions/Grind")

func free_character(character : Node):
	# called by character when getting out
	var i = 0
	for body in inside_bodies:
		if body == character:
			print(name+" free_character("+character.name+")")
			if character.has_node("Actions/Grind"):
				character.get_node("Actions/Grind").move_stop()
			else :
				printerr(body.name + " doesn't have a node called Actions/Grind")
			remove_body(i)
		i += 1

func remove_body(i : int):
	assert(i < inside_bodies.size())
	released_bodies[inside_bodies[i]] = cant_get_in_again_timer
	inside_bodies.remove(i)
	linear_velocities.remove(i)
	position_offsets.remove(i)

	path_follows[i].get_node("Particles").emitting = false
	paths_to_free[path_follows[i]] = path_follows[i].get_node("Particles").lifetime
	path_follows.remove(i)
