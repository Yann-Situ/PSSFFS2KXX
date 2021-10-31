extends Ball
# Rolling Heavy ball, with no bouncing and large mass
func _ready():
	self.mass = 2.0
	self.set_friction(0.0)
	self.set_bounce(0.001)
	$TrailHandler.set_node_to_trail(self)
	$TrailHandler.start(-1.0,0.1) # infinite trail
