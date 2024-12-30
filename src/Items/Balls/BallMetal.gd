extends Ball
# Metal ball, with no bouncing and large mass

#@export var attract_speed = 350#pix/s
@export var attract_player_radius = 45#pix
@export var destruction_speed_thresh = 300#pix/s
@export var destruction_momentum_min = 500##kg*pix/s
@export var destruction_momentum_max = 900##kg*pix/s

var friction_save

func _ready():
	super()

# func update_linear_velocity(delta):# apply gravity and forces
# 	linear_velocity.y += gravity * delta
# 	for force in applied_forces.values() :
# 		linear_velocity += invmass * force * delta
# 	if linear_velocity.length_squared() >= destruction_speed_thresh*destruction_speed_thresh:
# 		$SpeedParticles.emitting = true
# 	else :
# 		$SpeedParticles.emitting = false

func collision_effect(collider, collider_velocity, collision_point, collision_normal):
	var speed = (linear_velocity-collider_velocity).dot(collision_normal)
	if $ImpactTimer.is_stopped() and speed >= dust_threshold:
		$ImpactTimer.start()
		$Visuals/DustParticle.restart()
		if speed >= impact_threshold:
			GlobalEffect.make_impact(collision_point, impact_effect)
	if speed > destruction_speed_thresh:
		if collider.is_in_group("breakables"):
			var has_explode = collider.apply_explosion(
				-lerp(destruction_momentum_min, destruction_momentum_max,
					smoothstep(destruction_speed_thresh, 2*destruction_speed_thresh,
						linear_velocity.length())
					) * collision_normal)
			#add_impulse(mass*linear_velocity) # rebond or not rebond

func on_pickup(holder):
	$Visuals/SpeedParticles.emitting = false

################################################################################

func power_p(player,delta):
	attract_alterer.set_value(attract_force*(player.global_position - global_position).normalized())
func power_p_hold(player,delta):
	pass

func power_p_physics(player,delta):
	pass
func power_p_physics_hold(player,delta):
	pass

func power_jp(player,delta):
	add_accel(attract_alterer)
	remove_accel(Global.gravity_alterer)
	GlobalEffect.make_impact(self.global_position, impact_effect)
func power_jp_hold(player,delta):
	pass

func power_jr(player,delta):
	if has_accel(attract_alterer) :
		remove_accel(attract_alterer)
		add_accel(Global.gravity_alterer)
func power_jr_hold(player,delta):
	power_jr(player,delta)
