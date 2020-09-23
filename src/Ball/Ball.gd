extends RigidBody2D
# Classical ball
export (bool) var physics_enabled = true
var should_throw = false
var temporary_position = Vector2(0,0)
var temporary_velocity = Vector2(0,0)

func disable_physics():
	physics_enabled = false
	self.set_mode(RigidBody2D.MODE_STATIC)
	
	
func enable_physics():
	physics_enabled = true
	self.set_mode(RigidBody2D.MODE_CHARACTER)
	
func throw(posi, velo):
	should_throw = true
	temporary_position = posi
	temporary_velocity = velo

func _integrate_forces(state):
	if should_throw :
		should_throw = false
		state.transform.origin = temporary_position
		state.linear_velocity = temporary_velocity
