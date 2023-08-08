extends Ball

var local_gravity_alterer = AltererAdditive.new(Global.default_gravity)

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	remove_accel(Global.gravity_alterer)
	add_accel(local_gravity_alterer)

func set_local_gravity(angle : float):#radians
	local_gravity_alterer.set_value(Global.default_gravity.rotated(angle))

func collision_effect(collider, collider_velocity, collision_point, collision_normal):
	var speed = (linear_velocity-collider_velocity).dot(collision_normal)
	if speed >= dust_threshold:
		$Visuals/DustParticle.restart()
		if speed >= impact_threshold:
			GlobalEffect.make_impact(collision_point, impact_effect)
	set_local_gravity(Vector2.DOWN.angle_to(-collision_normal))

func power_p(player,delta):
	pass
func power_jp(player,delta):
	if holder is Player :
		holder.add_accel(local_gravity_alterer)
		holder.remove_accel(Global.gravity_alterer)

func power_jr(player,delta):
	if holder is Player :
		holder.remove_accel(local_gravity_alterer)
		holder.add_accel(Global.gravity_alterer)

func on_throw(previous_holder : Node):
	if previous_holder is Player :
		if previous_holder.has_accel(local_gravity_alterer):
			previous_holder.remove_accel(local_gravity_alterer)
			previous_holder.add_accel(Global.gravity_alterer)
