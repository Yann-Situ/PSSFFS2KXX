extends KinematicBody2D
class_name PhysicBody

export (bool) var physics_enabled = true
onready var start_position = global_position
onready var collision_layer_save = layers
var should_reset = false

#physics :
export (float) var gravity_scale = 1.0 setget set_gravity_scale, get_gravity_scale
export (float) var mass = 1.0 setget set_mass
export (float) var friction = 0.05 setget set_friction
export (float) var bounce = 0.5 setget set_bounce
var linear_velocity = Vector2(0.0,0.0) setget set_linear_velocity
var applied_force = Vector2(0.0,0.0) setget set_applied_force


onready var invmass = 1/mass
onready var gravity = gravity_scale*ProjectSettings.get_setting("physics/2d/default_gravity") # pix/s²

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

func set_linear_velocity(v):
	linear_velocity = v
func set_applied_force(force):
	applied_force=force

################################################################################
func _ready():
	Global.list_of_physical_nodes.append(self)
	if !Global.playing :
		disable_physics()
	add_to_group("physicbodies")

func disable_physics():
	physics_enabled = false
	linear_velocity *= 0
	applied_force *= 0
	layers = 0

func enable_physics():
	physics_enabled = true
	layers = collision_layer_save

func reset_position():
	position = start_position

func set_start_position(posi):
	start_position = posi
	global_position = posi

func apply_impulse(impulse):
	linear_velocity += invmass * impulse

func add_force(force):
	applied_force += force

###############PHYSICALPROCESS######################

func _physics_process(delta):
	if not physics_enabled:
		return
	update_linear_velocity(delta)
	var collision = move_and_collide(linear_velocity * delta, false)
	if collision and collision_effect(collision) :
		collision_handle(collision, delta)

func update_linear_velocity(delta):# apply gravity and forces
	linear_velocity.y += gravity * delta
	linear_velocity += invmass * applied_force * delta

func collision_effect(collision):
	pass
	return true

func collision_handle(collision, delta):
	var n = collision.normal
	var t = n.tangent()
	#normal_colision = n
	if collision.collider.is_in_group("physicbodies") : # TODO rather use PhysicBody but not allowed
		#color_colision = color3
		var m2 = collision.collider.mass
		var summass = m2 + mass
		var dist_vect = position-collision.collider.get_position()
		var speeddist = (linear_velocity - collision.collider_velocity).dot(dist_vect)
		linear_velocity -= 2*m2/summass*(speeddist/dist_vect.length_squared())*dist_vect
		collision.collider.set_linear_velocity(collision.collider_velocity + 2*mass/summass*(speeddist/dist_vect.length_squared())*dist_vect)
		#collision.collider.apply_impulse(2*m2*mass/summass*(speeddist/dist_vect.length_squared())*dist_vect)#doesn't work don't know Y
		move_and_collide(collision.remainder.bounce(collision.normal),false)#may cause pb on corners ?
	else:
		var bounce_linear_velocity = bounce*linear_velocity.bounce(n)
		var vel_n = n.dot(bounce_linear_velocity)
		var vel_t
		var motion
		if vel_n < 2.5*gravity*delta:
			#TODO seuil à déterminer
			#sliding
			#color_colision = color1
			vel_t = lerp(t.dot(linear_velocity), 0, friction)
			linear_velocity = vel_t*t
			motion = collision.remainder.dot(t)*t
			move_and_collide(motion,false)
			#linear_velocity = move_and_slide(linear_velocity,n,false,4,0.79,false)
		else :
			#bouncing
			#color_colision = color2
			vel_t = lerp(t.dot(bounce_linear_velocity), 0, friction)
			linear_velocity = vel_n*n + vel_t*t
			motion = collision.remainder.bounce(n)
			move_and_collide(motion,false)#may cause pb on corners ?
