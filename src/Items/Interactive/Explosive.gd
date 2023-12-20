@icon("res://assets/art/icons/explosive.png")
extends CollisionObject2D
class_name Explosive

signal exploding_break(momentum)
signal exploding_electric(momentum)
signal exploding_impulse(momentum)
signal exploding_damage(damage_value, damage_duration)

func _ready():
	add_to_group("breakables")
	add_to_group("electrics")
	# add_to_group("impulsables")
	add_to_group("damageables")

func explode(momentum_break : float = 0.0, \
	momentum_electric : float = 0.0, \
	momentum_impulse : float = 0.0, \
	damage_value : float = 0.0, damage_duration : float = 0.0 ):
	if get_collision_layer_value(6): # breakable
		exploding_break.emit(momentum_break)
	if get_collision_layer_value(7): # electric
		exploding_electric.emit(momentum_electric)
	if get_collision_layer_value(0) or get_collision_layer_value(2): # player & ball
		exploding_impulse.emit(momentum_impulse)
	if get_collision_layer_value(8): # damageable
		exploding_damage.emit(damage_value, damage_duration)
