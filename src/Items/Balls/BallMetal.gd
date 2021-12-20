extends Ball
# Metal ball, with no bouncing and large mass

export var attract_force = 2000#kg*pix/s^2
export var destruction_speed_thresh = 300#pix/s
export var destruction_momentum_min = 200##kg*pix/s
export var destruction_momentum_max = 500##kg*pix/s

func _ready():
	self.mass = 3.0
	self.set_friction(0.007)
	self.set_bounce(0.0)
	$TrailHandler.set_node_to_trail(self)


func update_linear_velocity(delta):# apply gravity and forces
	linear_velocity.y += gravity * delta
	for force in applied_forces.values() :
		linear_velocity += invmass * force * delta
	if linear_velocity.length_squared() >= destruction_speed_thresh*destruction_speed_thresh:
		$SpeedParticles.emitting = true
	else :
		$SpeedParticles.emitting = false

func collision_effect(collider, collider_velocity, collision_point, collision_normal):
	if (linear_velocity-collider_velocity).length() > dust_threshold:
		$DustParticle.restart()
	if (linear_velocity-collider_velocity).dot(-collision_normal) > destruction_speed_thresh:
		if collider.is_in_group("breakables"):
			collider.apply_explosion(
				-lerp(destruction_momentum_min, destruction_momentum_max,
					smoothstep(destruction_speed_thresh, 2*destruction_speed_thresh,
						linear_velocity.length())
					) * collision_normal)
			return false
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
		self.set_friction(0.007)

func on_pickup(holder):
	$SpeedParticles.emitting = false
