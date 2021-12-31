#tool
extends Path2D
class_name RailLine, "res://assets/art/icons/railline.png"

export (bool) var invert_line_direction = false
export (float) var character_position_offset = -32.0
export (float) var character_position_entrance_tolerance = -16.0
export (float) var character_collision_offset = -52.0

var _particle = preload("res://src/Effects/RideParticles.tscn")

var init_point = Vector2.ZERO
var final_point = Vector2.ZERO

var collision_segments = []

var inside_bodies = []
var path_follows = []
var linear_velocities = []
var position_offsets = []

var real_character_offset = Vector2.ZERO

onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") # pix/s²
onready var character_offset = Vector2(0.0,character_position_offset)
onready var collision_offset = Vector2(0.0,0.0)

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
	if curve.get_point_count() >= 2:
		#print(self.name + " setcurve")
		final_point = curve.get_point_position(curve.get_point_count()-1)
		#print(final_point)
	else :
		print(self.name+" Error: not enough points in the curve!")
	_update_points()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var paths_to_remove = []
	
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
		
		linear_velocities[i-j] = velocity
		position_offsets[i-j]  = position_offset
		if path_follow.get_unit_offset() == 1.0 or \
		   path_follow.get_unit_offset() == 0.0 or \
		   body.S.crouch_p :
			
			body.enable_physics()
			body.S.velocity = velocity
			inside_bodies.remove(i-j)
			paths_to_remove.push_back(path_follows[i-j])
			path_follows.remove(i-j)
			linear_velocities.remove(i-j)
			position_offsets.remove(i-j)
			$Timer.start()
			print(body.name+" quit "+self.name)
			#body.throw(path_follow.global_position,
			#			path_follow.transform.x * speed_at_exit)
			j += 1 # because we deleted a node in the list we're browsing
			
			# the following code can result in wrong j and i values if there are
			# multiple character on trail... 
			# A workaround would be to queue_free and stop emitting after the
			# for loop.
#			temp_particles.emitting = false
#			yield(get_tree().create_timer(temp_particles.lifetime), "timeout") 
#			temp_path_follow.call_deferred("queue_free") 

	# Ugly but it works :
	if not paths_to_remove.empty():
		var lifetime = paths_to_remove[0].get_node("Particles").lifetime
		for p in paths_to_remove:
			p.get_node("Particles").emitting = false
		yield(get_tree().create_timer(lifetime), "timeout") 
		for p in paths_to_remove:
			p.call_deferred("queue_free") 

func _on_Area_body_entered(body):
	if not body.is_in_group("characters") or not $Timer.is_stopped() :
		return
		
	var bi = body.global_position-global_position-init_point
	var closest_offset = curve.get_closest_offset(bi)
	var closest_point = curve.interpolate_baked(closest_offset)
	
	if (bi-closest_point).y <= character_position_entrance_tolerance :

		for b in inside_bodies:
			if b == body:
				print(body.name+" already in "+self.name)
				return 1
		
		print(body.name+" on "+self.name)
		
		var new_path_follow : PathFollow2D = PathFollow2D.new()
		new_path_follow.loop = false
		var ride_particle : Particles2D = _particle.instance()
		ride_particle.name = "Particles"
		if invert_line_direction:
			ride_particle.process_material.direction.y = 1
		new_path_follow.add_child(ride_particle)
		self.add_child(new_path_follow)
		
		new_path_follow.offset = closest_offset # approximate where the player is
		var rail_dir = new_path_follow.transform.x

		inside_bodies.push_back(body)
		path_follows.push_back(new_path_follow)
		body.S.velocity = body.S.velocity.dot(rail_dir) * rail_dir
		linear_velocities.push_back(body.S.velocity)
		position_offsets.push_back(body.global_position-new_path_follow.global_position)
		body.disable_physics()
