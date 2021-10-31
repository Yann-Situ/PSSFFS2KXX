extends Ball
# Metal ball, with no bouncing and large mass
func _ready():
	self.mass = 3.0
	self.set_friction(0.4)
	self.set_bounce(0.1)
