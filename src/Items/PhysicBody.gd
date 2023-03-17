# A generic PhysicBody class that can handle collisions and impulse.
extends CharacterBody2D
class_name PhysicBody
# @icon("res://assets/art/icons/physicbody.png")

@export var physics_enabled : bool = true
var should_reset = false

#physics :
@export var gravity_scale : float = 1.0 : get = get_gravity_scale, set = set_gravity_scale
@export var mass : float = 1.0 : set = set_mass
@export var friction : float = 0.5 : set = set_friction
@export var bounce : float = 0.5 : set = set_bounce
@export var penetration : float = 0.5 :
	set = set_penetration # for penetration in the wind
var linear_velocity = Vector2(0.0,0.0) : set = set_linear_velocity
var applied_forces = {} #"force_name : value in kg*pix/s^2"

@onready var start_position = global_position
@onready var collision_layer_save = collision_layer
@onready var collision_mask_save = collision_mask
@onready var invmass = 1/mass
@onready var gravity = gravity_scale*ProjectSettings.get_setting("physics/2d/default_gravity") # pix/s²

func set_gravity_scale(v):
	gravity_scale = v
	gravity = gravity_scale*ProjectSettings.get_setting("physics/2d/default_gravity")
func get_gravity_scale():
	return gravity_scale
func set_mass(m):
	mass = m
	invmass = 1/mass

func set_friction(new_value):
	friction = new_value
func set_bounce(new_value):
	bounce = new_value
func set_penetration(new_value):
	penetration = new_value

func set_linear_velocity(v):
	linear_velocity = v

################################################################################
func _ready():
	Global.list_of_physical_nodes.append(self)
	if !Global.playing or !physics_enabled:
		disable_physics()
	add_to_group("physicbodies")

func disable_physics():
	physics_enabled = false
	linear_velocity *= 0
	applied_forces.clear()
	collision_layer = 0
	collision_mask = 0 # in Godot 3.x I just wrote 'layers = 0', don't remember why (?)
	set_physics_process(false)

func enable_physics():
	physics_enabled = true
	collision_layer = collision_layer_save
	collision_mask = collision_mask_save
	set_physics_process(true)

func reset_position():
	global_position = start_position

func set_start_position(position : Vector2):
	start_position = position
	global_position = position

func apply_impulse(impulse):
	linear_velocity += invmass * impulse

func has_force(name : String):
	return applied_forces.has(name)

func apply_force(force : Vector2, name : String):
	applied_forces[name] = force

func remove_force(name : String):
	applied_forces.erase(name)

###############PHYSICALPROCESS######################

func _physics_process(delta):
	physics_process(delta)

func physics_process(delta):
	var collision = move_and_collide(linear_velocity * delta, false)
	if collision and collision_effect(collision.get_collider(),
		collision.get_collider_velocity(), collision.get_position(), collision.get_normal()) :
		collision_handle(collision, delta)
	update_linear_velocity(delta)

func update_linear_velocity(delta):# apply gravity and forces
	linear_velocity.y += gravity * delta
	for force in applied_forces.values() :
		linear_velocity += invmass * force * delta

func collision_effect(collider : Object, collider_velocity : Vector2,
	collision_point : Vector2, collision_normal : Vector2):
	pass
	# this function does NOT aim to change self.linear_velocity, this can result in
	# wrong behaviours
	return true

func collision_handle(collision, delta):
	var n = collision.get_normal()
	var t = n.orthogonal()    
	#normal_colision = n
	if collision.get_collider().is_in_group("physicbodies") :
		var m2 = collision.get_collider().mass
		var summass = m2 + mass
		var dist_vect = global_position-collision.get_collider().get_global_position()
		var speeddist = (linear_velocity - collision.get_collider_velocity()).dot(dist_vect)
		linear_velocity -= 2*m2/summass*(speeddist/dist_vect.length_squared())*dist_vect
		collision.get_collider().set_linear_velocity(collision.get_collider_velocity() + 2*mass/summass*(speeddist/dist_vect.length_squared())*dist_vect)
		#collision.get_collider().apply_impulse(2*m2*mass/summass*(speeddist/dist_vect.length_squared())*dist_vect)#doesn't work don't know Y

		# see https://docs.godotengine.org/fr/stable/classes/class_kinematiccollision2d.html#class-kinematiccollision2d-property-collider
		# and call `collision_effect` on the collider with the right `collision`
		# object. This requires to change collider, angle, normal etc.
		collision.get_collider().collision_effect(self,linear_velocity, \
			collision.get_position(), collision.get_normal())

		move_and_collide(collision.get_remainder().bounce(collision.get_normal()),false)#may cause pb on corners ?

	else:
		var bounce_linear_velocity = bounce*linear_velocity.bounce(n)
		var vel_n = n.dot(bounce_linear_velocity)
		if vel_n < 2.5*gravity*delta:
			#TODO seuil à déterminer
			#sliding
			#color_colision = color1
			#var vel_t = lerp(t.dot(linear_velocity), 0, friction)
			var vel_t = GlobalMaths.apply_friction(t.dot(linear_velocity), friction, delta)
			linear_velocity = vel_t*t
			var motion = collision.get_remainder().dot(t)*t
			move_and_collide(motion,false)
			set_velocity(linear_velocity)
			set_up_direction(n)
			set_floor_stop_on_slope_enabled(false)
			set_max_slides(4)
			set_floor_max_angle(0.79)
			# TODOConverter40 infinite_inertia were removed in Godot 4.0 - previous value `false`
			move_and_slide()
			#linear_velocity = velocity
		else :
			#bouncing
			#color_colision = color2
			#var vel_t = lerp(t.dot(bounce_linear_velocity), 0, friction)
			var vel_t = GlobalMaths.apply_friction(t.dot(bounce_linear_velocity), friction, delta)
			linear_velocity = vel_n*n + vel_t*t
			var motion = collision.get_remainder().bounce(n)
			move_and_collide(motion,false)#may cause pb on corners ?
