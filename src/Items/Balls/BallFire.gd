extends Ball
# Fire ball, break/burn things and disapear on bounce

@export var destruction_momentum = 20##kg*pix/s

var friction_save

func _ready():
	super()

func collision_effect(collider, collider_velocity, collision_point, collision_normal):
	destruction(0.01)
	if collider.is_in_group("breakables"):
		return !collider.apply_explosion(destruction_momentum  * collision_normal)

func on_pickup(holder):
	pass

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
func power_jp_hold(player,delta):
	pass

func power_jr(player,delta):
	if has_accel(attract_alterer) :
		remove_accel(attract_alterer)
		add_accel(Global.gravity_alterer)
func power_jr_hold(player,delta):
	power_jr(player,delta)
