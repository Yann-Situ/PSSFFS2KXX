extends Ball
# Fire ball, break/burn things and disapear on bounce

export var attract_force = 500#kg*pix/s^2
export var destruction_momentum = 20##kg*pix/s

var friction_save

func _ready():
	self.mass = 1.0
	self.set_friction(0.05)
	friction_save = friction
	self.set_bounce(0.5)
	$Effects/TrailHandler.set_node_to_trail(self)

func collision_effect(collider, collider_velocity, collision_point, collision_normal):
	if (linear_velocity-collider_velocity).length() > dust_threshold:
		$Effects/DustParticle.restart()
	if collider.is_in_group("breakables"):
		return !collider.apply_explosion(destruction_momentum  * collision_normal)
	return true

func power_p(player,delta):
	if holder == null :
		add_force("player_attract", \
			attract_force*(player.position - position).normalized() + \
			mass * gravity * Vector2.UP)
		self.set_friction(0.0)

func power_jp(player,delta):
	linear_velocity = Vector2.ZERO
	
func power_jr(player,delta):
	if holder == null :
		remove_force("player_attract")
		self.set_friction(friction_save)

func on_pickup(holder):
	pass
