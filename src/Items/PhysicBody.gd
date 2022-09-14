# A generic PhysicBody class that can handle collisions and impulse.
extends KinematicBody2D
class_name PhysicBody, "res://assets/art/icons/physicbody.png"

export (bool) var physics_enabled = true
var should_reset = false

#physics :
export (float) var gravity_scale = 1.0 setget set_gravity_scale, get_gravity_scale
export (float) var mass = 1.0 setget set_mass
export (float) var friction = 0.05 setget set_friction
export (float) var bounce = 0.5 setget set_bounce
export (bool) var is_on_path = false setget set_is_on_path
var linear_velocity = Vector2(0.0,0.0) setget set_linear_velocity
var applied_forces = {} #"force_name : value in kg*pix/s^2"

onready var start_position = global_position
onready var last_position = start_position
onready var collision_layer_save = collision_layer
onready var collision_mask_save = collision_mask
onready var invmass = 1/mass
onready var gravity = gravity_scale*ProjectSettings.get_setting("physics/2d/default_gravity") # pix/s²
onready var sqrt_c_gravity = sqrt(4*gravity)

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

func set_is_on_path(new_value : bool):
	is_on_path = new_value

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
	layers = 0
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
	if !is_on_path:
		linear_velocity += invmass * impulse

func add_force(name : String, force : Vector2):
	applied_forces[name] = force

func remove_force(name : String):
	applied_forces.erase(name)

###############PHYSICALPROCESS######################

func _physics_process(delta): # don't remember why it is useful to have this duplicate
	if !is_on_path:
		physics_process(delta)
	else:
		set_linear_velocity(0.5*linear_velocity +0.5/delta * (global_position-last_position))
	last_position = global_position

func physics_process(delta):
	color_collision(0)
	var collision = move_and_collide(linear_velocity * delta, false)
	if collision and collision_effect(collision.collider,
		collision.collider_velocity, collision.position, collision.normal) :
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

func collision_handle(collision : KinematicCollision2D, delta : float):
	# https://fr.wikipedia.org/wiki/Collision_in%C3%A9lastique
	var n = collision.normal
	var t = n.tangent()
	#normal_colision = n
	if collision.collider.is_in_group("physicbodies") and !collision.collider.is_on_path :
		color_collision(1)
		# see https://docs.godotengine.org/fr/stable/classes/class_kinematiccollision2d.html#class-kinematiccollision2d-property-collider
		# and call `collision_effect` on the collider with the right `collision`
		# object. This requires to change collider, angle, normal etc.
		collision.collider.collision_effect(self, linear_velocity, \
			collision.position, collision.normal)

		var m2 = collision.collider.mass
		var inv_sum_mass = 1/(m2 + mass)
		# computation of coeff of restitution (bounce coeff during an inelastic
		# choc). It is a handmade computation, but it works if mass is near
		# infinite
		var restitution_coeff = bounce * m2 + collision.collider.bounce * mass
		restitution_coeff *= inv_sum_mass
		var temp_coeff = 1.0+restitution_coeff
		var vel_dif = (linear_velocity - collision.collider_velocity).dot(n)*n

		#linear_velocity -= 2*m2*inv_sum_mass*vel_dif
		linear_velocity -= temp_coeff*m2*inv_sum_mass*vel_dif

		#collision.collider.set_linear_velocity(collision.collider_velocity + 2*mass/summass*vel_dif)
		collision.collider.apply_impulse(temp_coeff*mass*inv_sum_mass*vel_dif)

		var motion = collision.remainder.bounce(n)
		move_and_collide(motion,false)#may cause pb on corners ?

	else:
		var bounce_linear_velocity = linear_velocity.bounce(n)
		var vel_n = bounce*bounce_linear_velocity.dot(n)

		# Critieria for friction instead of bounce: if the height of the bounce is under c pixels
		# then friction. #TODO seuil à déterminer
		# Height of bounce is 0.5*v/g where v is the vertical speed
		#0.5*v^2/g < c pix => v < sqrt(2*c*pix*g)
		if vel_n < sqrt_c_gravity:
			color_collision(2)
			# Friction Part
			# only apply friction on the tangential part of the bounce
#
#			if "linear_velocity" in collision.collider:
#				var vel_t = apply_friction((linear_velocity-collision.collider.linear_velocity).dot(t), friction*500, delta)
#				linear_velocity = vel_t*t + collision.collider.linear_velocity
#			else :
			var vel_t = apply_friction((linear_velocity-collision.collider_velocity).dot(t), friction*500, delta)
			linear_velocity = vel_t*t + collision.collider_velocity
			var motion = collision.remainder.dot(t)*t
			move_and_collide(motion,false)
			#linear_velocity = move_and_slide(linear_velocity,n,false,4,0.79,false)
		else :
			color_collision(3)
			# Bouncing Part
			# apply friction on the tangential part of the bounce and bounce on the normal part
			var vel_t = apply_friction(bounce_linear_velocity.dot(t), friction*500, delta)
			linear_velocity = vel_n*n + vel_t*t
			var motion = collision.remainder.bounce(n)
			move_and_collide(motion,false)
			# TODO
			# Warning : may cause pb on corners ?
			# Error : infinite bounce in some cases due to approximation

func apply_friction(relative_velocity : float, friction_decel : float, delta : float):
	var d = max(abs(relative_velocity) - friction_decel*delta, 0.0)
	return sign(relative_velocity) * d

func color_collision(i : int):
	if i == 0:
		self.modulate = Color.white
	if i == 1:
		self.modulate = Color.red
	if i == 2:
		self.modulate = Color.green
	if i == 3:
		self.modulate = Color.blue
