extends Ball
# Rolling Heavy ball, with no bouncing and large mass
func _ready():
	self.mass = 2.0
	self.set_friction(0.0)
	self.set_bounce(0.001)

#func on_pickup(holder_node : Node):
#	get_node("TrailInstance").z_index = z_index - 1
#
func power_p(player,delta):
	pass

func power_jp(player,delta):
	if holder == player:
		# player.gravity = Vector2.ZERO
		# deprecated
		pass

func power_jr(player,delta):
	if holder == player:
		# player.gravity = player.based_gravity
		# deprecated
		pass
