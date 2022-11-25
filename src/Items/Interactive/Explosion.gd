extends Area2D
class_name Explosion#, "res://assets/art/icons/targeted.png"
# Explosion.gd :
# Handle a single explosion from a source point
signal body_explode(body, direction)

export (bool) var simple_explosion = true # whether or not use the Explosion.explode_body function when body explode
export (float) var breakable_momentum = 0.0 #kg.pix/s
export (float) var electric_momentum = 0.0 #kg.pix/s
export (float) var physicbody_momentum = 0.0 #kg.pix/s
export (float) var damage = 0.0 #hp
export (float) var damage_duration = 0.0 #s
export (float) var initial_scale_factor = 1.0
# the explosion goes from 'initial_scale_factor * momentum' at the center,
# to  'momentum' at the radius. Doesn't apply to damages.

export (float) var duration = 0.5 #s
export (int,1,10) var explosion_steps = 3
export (Shape2D) var collision_shape setget set_collision_shape

export (Array) var body_exceptions = []

var exploded_bodies = [] # [body]
var shape_radius

func set_collision_shape(s : Shape2D):
	collision_shape = s
	if s is CircleShape2D:
		shape_radius = s.radius
	elif s is CapsuleShape2D:
		shape_radius = s.height
	elif s is RectangleShape2D:
		shape_radius = max(s.extents.x, s.extents.y)
	elif s is RayShape2D:
		shape_radius = s.length
	elif s is SegmentShape2D:
		shape_radius = 0.5*(s.A-s.B).length()
	else:
		shape_radius = 0.0
		push_warning("this Shape2D sub node is not handled for explosion.")

func _ready():
	var collision_node = CollisionShape2D.new()
	collision_node.shape = collision_shape
	add_child(collision_node)
	collision_layer = 16
	collision_mask = 1+4+64+128+256
	if simple_explosion:
		connect("body_explode", self, "explode_body")
	print("BOUM_ready "+str(duration))
	explode()

func explode():
	# init part:
	if duration <= 0.0:
		explosion_steps = 1
	var time_step = duration*1.0/explosion_steps
	print(time_step)

	# process part:
	for i in range(explosion_steps):
		var criteria = shape_radius * (i+1)/explosion_steps
		criteria *= criteria
		var scale_factor = lerp(initial_scale_factor, 1.0, i/explosion_steps)
		# wait for time_step seconds
		yield(get_tree().create_timer(time_step), "timeout")
		# process bodies
		var bodies = get_overlapping_bodies()+get_overlapping_areas()
		print(bodies)
		for body in bodies:
			if !body in exploded_bodies and !body in body_exceptions:
				var d = (body.global_position-global_position)
				if d.length_squared() <= criteria:
					emit_signal("body_explode", body, scale_factor*d.normalized())
					#explode_body(body, scale_factor*d.normalized())
					exploded_bodies.push_back(body)
	print("BOUM queue_free")
	queue_free()

func explode_body(body : Node2D, direction : Vector2):
	if body.is_in_group("breakables"):
		body.apply_explosion(breakable_momentum*direction)
	if body.is_in_group("electrics"):
		body.apply_shock(electric_momentum*direction)
	if body.is_in_group("physicbodies") or body is Player:
		body.apply_impulse(physicbody_momentum*direction)
	if body.is_in_group("damageables"):
		body.apply_damage(damage, damage_duration)
