@icon("res://assets/art/icons/physicbody.png")
# A generic PhysicBody class that can handle collisions and impulse.
extends RigidBody2D
class_name SituBody

#physics :
@export var physics_enabled : bool = true
@onready var start_position : Vector2 = global_position : set=set_start_position
@onready var collision_layer_save = collision_layer
@onready var collision_mask_save = collision_mask

@onready var force_alterable = Alterable.new(Vector2.ZERO)
@onready var accel_alterable = Alterable.new(Vector2.ZERO)

@onready var invmass : float = 1.0/mass

var _override_impulse_bool = false
var _override_impulse_value = Vector2.ZERO

func _set(_name, value):
	match _name:
		"mass":
			mass = value
			if value == 0:
				invmass = INF
			else:
				invmass = 1.0/mass

func set_start_position(_position : Vector2):
	start_position = _position

################################################################################
func _ready():
	Global.list_of_physical_nodes.append(self)
	if !Global.playing or !physics_enabled:
		disable_physics()
	add_to_group("situbodies")

	set_gravity_scale(0.0) # we compute gravity using accel_alterer
	set_max_contacts_reported(4)
	set_lock_rotation_enabled(true)
	add_accel(Global.gravity_alterer)

func disable_physics():
	physics_enabled = false
	set_freeze_enabled(true)
	collision_layer = 0
	collision_mask = 0
	set_linear_velocity(Vector2.ZERO)
	_override_impulse_bool = false

func enable_physics():
	physics_enabled = true
	collision_layer = collision_layer_save
	collision_mask = collision_mask_save
	set_freeze_enabled(false)

func reset_physics():
	disable_physics()
	global_position = start_position
	enable_physics()

###############PHYSICALPROCESS######################
###########################################################
func _integrate_forces(state):
	for i in state.get_contact_count():
		collision_effect(state.get_contact_collider_object(i), \
			state.get_contact_collider_velocity_at_position(i), \
			state.get_contact_local_position(i), \
			state.get_contact_local_normal(i))

	constant_force = force_alterable.get_value()
	constant_force += mass*accel_alterable.get_value()
	if _override_impulse_bool:
		print(self.name+" integrate_override")
		var d = _override_impulse_value.normalized()
		add_impulse(-mass*linear_velocity.dot(d)*d + _override_impulse_value)
		_override_impulse_bool = false

func collision_effect(collider : Node, collider_velocity : Vector2, collision_point : Vector2, collision_normal : Vector2):
	pass

func has_force(force_alterer : Alterer):
	return force_alterable.has_alterer(force_alterer)
func add_force(force_alterer : Alterer):
	force_alterable.add_alterer(force_alterer)
func remove_force(force_alterer : Alterer):
	force_alterable.remove_alterer(force_alterer)

func has_accel(accel_alterer : Alterer):
	return accel_alterable.has_alterer(accel_alterer)
func add_accel(accel_alterer : Alterer):
	accel_alterable.add_alterer(accel_alterer)
func remove_accel(accel_alterer : Alterer):
	accel_alterable.remove_alterer(accel_alterer)

#func add_speed(speed_alterer : Alterer):
#	speed_alterable.add_alterer(speed_alterer)
#func remove_speed(speed_alterer : Alterer):
#	speed_alterable.remove_alterer(speed_alterer)

func add_impulse(impulse : Vector2):
	_on_impulse(impulse)
	apply_impulse(impulse)

## designed to apply an impulse but cancelling the previous velocity in the same
## direction as the impulse. Typically used by jumpers.
## The necessity of such a function is due to the fact that apply_impulse does
## not modify immediatly the velocity, so we need to reset the velocity once per
## physics frame at maximum.
## The last call of this function in the same frame will be aplied.
func override_impulse(impulse : Vector2):
	if physics_enabled:
		#print("impulse_override")
		_override_impulse_bool = true
		_override_impulse_value = impulse

func get_force():
	force_alterable.get_value()

func _on_impulse(impulse : Vector2):
	pass
###########################################################
