extends RigidBody2D
# Classical ball
export (bool) var physics_enabled = true

func disable_physics():
	physics_enabled = false
	self.set_mode(RigidBody2D.MODE_STATIC)
	
	
func enable_physics():
	physics_enabled = true
	self.set_mode(RigidBody2D.MODE_CHARACTER)
	

