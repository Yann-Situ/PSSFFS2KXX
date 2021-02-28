extends RigidBody2D

# Classical ball
export (bool) var physics_enabled = true
onready var collision = $collision
onready var start_position = global_position
var should_reset = false
var temporary_position = Vector2(0,0)
var temporary_velocity = Vector2(0,0)

func _ready():
	self.mass = 1.0
	self.set_friction(0.15)
	self.set_bounce(0.5)
	Global.list_of_physical_nodes.append(self)
	if !Global.playing :
		disable_physics()

############################################
# The three following functions should be in any physical item that can be picked/placed.

func disable_physics():
	physics_enabled = false
	self.set_mode(RigidBody2D.MODE_STATIC)
	collision.disabled = true
	#Just In Case
	linear_velocity *= 0
	angular_velocity *= 0


func enable_physics():
	physics_enabled = true
	self.set_mode(RigidBody2D.MODE_CHARACTER)
	collision.disabled = false

func reset_position():
	throw(start_position, Vector2(0.0,0.0))

# Should be in any items that can be picked/placed
func set_start_position(posi):
	start_position = posi
	global_position = posi

###########################################################

func throw(posi, velo):
	should_reset = true
	temporary_position = posi
	temporary_velocity = velo

func _integrate_forces(state):
	if should_reset :
		should_reset = false
		state.transform.origin = temporary_position
		state.linear_velocity = temporary_velocity
	# if state.linear_velocity.length() > 400:
	# 	var d = min(state.linear_velocity.length()/400 - 1, 0.2)
	# 	$Sprite.scale = (Vector2(1+d,1-d))
	# 	$Sprite.rotation = (state.linear_velocity.angle())
	# else :
	# 	$Sprite.scale = (Vector2(1,1))
	# 	$Sprite.rotation = (0)
	integrate_forces_child(state)

func integrate_forces_child(state):
	pass
