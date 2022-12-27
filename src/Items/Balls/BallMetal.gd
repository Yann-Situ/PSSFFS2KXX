extends Ball
# Metal ball, with no bouncing and large mass

#export var attract_force = 2000#kg*pix/s^2
export var attract_speed = 350#pix/s
export var attract_player_radius = 45#pix
export var destruction_speed_thresh = 300#pix/s
export var destruction_momentum_min = 500##kg*pix/s
export var destruction_momentum_max = 900##kg*pix/s

var friction_save

func _ready():
	self.mass = 3.0
	self.set_friction(0.02)
	friction_save = friction
	self.set_bounce(0.0)
	self.set_penetration(0.1)


func update_linear_velocity(delta):# apply gravity and forces
	linear_velocity.y += gravity * delta
	for force in applied_forces.values() :
		linear_velocity += invmass * force * delta
	if linear_velocity.length_squared() >= destruction_speed_thresh*destruction_speed_thresh:
		$SpeedParticles.emitting = true
	else :
		$SpeedParticles.emitting = false

func collision_effect(collider, collider_velocity, collision_point, collision_normal):
	var speed = (linear_velocity-collider_velocity).length()
	if $ImpactTimer.is_stopped() and speed >= dust_threshold:
		$ImpactTimer.start()
		$Effects/DustParticle.restart()
		if speed >= impact_threshold:
			var impact = impact_particles[impact_effect].instance()
			get_parent().add_child(impact)
			impact.global_position = collision_point
			impact.start()
	if (linear_velocity-collider_velocity).dot(-collision_normal) > destruction_speed_thresh:
		if collider.is_in_group("breakables"):
			var has_explode = collider.apply_explosion(
				-lerp(destruction_momentum_min, destruction_momentum_max,
					smoothstep(destruction_speed_thresh, 2*destruction_speed_thresh,
						linear_velocity.length())
					) * collision_normal)
			return !has_explode
	return true

func power_p(player,delta):
	if holder == null :
#		add_force("player_attract", \
#			attract_force*(player.position - position).normalized() + \
#			mass * gravity * Vector2.UP)
		var d = player.global_position - global_position
		self.set_linear_velocity(attract_speed*\
			smoothstep(0.0,attract_player_radius,d.length())*d.normalized())
		self.set_friction(0.0)

func power_jp(player,delta):
	#linear_velocity = Vector2.ZERO
	pass

func power_jr(player,delta):
	if holder == null :
		#remove_force("player_attract")
		self.set_friction(friction_save)

func on_pickup(holder):
	$SpeedParticles.emitting = false
