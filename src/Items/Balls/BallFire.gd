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

func power_p(player,delta):
	if holder == Global.get_current_room() :
		attract_alterer.set_value(attract_force*(player.global_position - global_position).normalized())

func power_jp(player,delta):
	if holder == Global.get_current_room() :
		add_accel(attract_alterer)
		remove_accel(Global.gravity_alterer)

func power_jr(player,delta):
	if has_accel(attract_alterer) :
		remove_accel(attract_alterer)
		add_accel(Global.gravity_alterer)

func on_pickup(holder):
	pass
