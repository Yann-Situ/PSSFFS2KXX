extends Ball
# Rolling Heavy ball, with no bouncing and large mass
func _ready():
	self.mass = 2.0
	self.set_friction(0.0)
	self.set_bounce(0.001)

#func on_pickup(holder_node : Node):
#	get_node("TrailInstance").z_index = z_index - 1
