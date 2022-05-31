extends Ball
# Rolling Heavy ball, with no bouncing and large mass
func _ready():
	self.mass = 2.0
	self.set_friction(0.0)
	self.set_bounce(0.001)
	$Effects/TrailHandler.set_node_to_trail(self)
	$Effects/TrailHandler.start(-1.0,0.1) # infinite trail

#func on_pickup(holder_node : Node):
#	get_node("TrailInstance").z_index = z_index - 1

func collision_effect(collider, collider_velocity, collision_point, collision_normal):
	var speed = (linear_velocity-collider_velocity).length()
	if speed > dust_threshold:
		$Effects/DustParticle.restart()
		if speed > impact_threshold:
			var impact = impact_particles0.instance()
			get_parent().add_child(impact)
			impact.global_position = collision_point
			impact.start()
	return true
