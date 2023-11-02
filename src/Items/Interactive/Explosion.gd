@icon("res://assets/art/icons/explosion.png")
extends Area2D
class_name Explosion
# Explosion.gd :
# Handle a single explosion from a source point

@export var explosion_data : ExplosionData
var exploded_bodies = [] # [body]

func _ready():
	if explosion_data.collision_shape == null:
		push_warning("null collision_shape: queue_free() without exploding.")
		queue_free()
		return
	var collision_node = CollisionShape2D.new()
	collision_node.shape = explosion_data.collision_shape

	# TODO: error here
	call_deferred("add_child", collision_node)
	#	E 0:01:47:0254   Explosion.gd:45 @ _ready(): Can't change this state while flushing queries. Use call_deferred() or set_deferred() to change monitoring state instead.
	#  <Erreur C++>   Condition "area->get_space() && flushing_queries" is true.
	#  <C++ Source>   servers/physics_2d/godot_physics_server_2d.cpp:355 @ area_set_shape_disabled()
	#  <Pile des appels>Explosion.gd:45 @ _ready()
	#                 GlobalEffect.gd:46 @ make_simple_explosion()
	#                 BallBoum.gd:54 @ boum()
	#                 BallBoum.gd:19 @ collision_effect()
	#                 SituBody.gd:63 @ _integrate_forces()
	collision_layer = 16
	collision_mask = 1+4+64+128+256
	#print("BOUM explode!")
	await get_tree().physics_frame # in order to catch the bodies at the first explosion step
	call_deferred("explode")

func explode():
	# init part:
	if explosion_data.explosion_duration <= 0.0:
		explosion_data.explosion_steps = 1
	var time_step = explosion_data.explosion_duration*1.0/explosion_data.explosion_steps
	#print(time_step)

	# process part:
	for i in range(explosion_data.explosion_steps):
		var criteria = explosion_data.shape_radius * (i+1)/explosion_data.explosion_steps
		criteria *= criteria
		var scale_factor = lerp(explosion_data.initial_scale_factor, 1.0, (1.0*i)/explosion_data.explosion_steps)
		# wait for time_step seconds
		await get_tree().create_timer(time_step).timeout
		# process bodies
		var bodies = get_overlapping_bodies()+get_overlapping_areas()
		#print(bodies)
		for body in bodies:
			if !body in exploded_bodies and !body in explosion_data.body_exceptions:
				var d = (body.global_position-global_position)
				if d.length_squared() <= criteria or i == explosion_data.explosion_steps-1:
					explosion_data.body_explode.emit(body, scale_factor*d.normalized())
					exploded_bodies.push_back(body)
					#TODO : we actually need to check the nearest point of the body and not its center.
					# A workaround would be to use explosion_steps collision_shapes (or Area2D).
					# The actual workaround is to add the i == explosion_data.explosion_steps-1
					# condition to not miss the last objects
	#print("BOUM queue_free")
	call_deferred("queue_free")
