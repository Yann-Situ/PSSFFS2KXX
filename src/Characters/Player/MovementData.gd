## MovementData:
# should store:
#	velocity
#
# 	acceleration alterable
# 	force alterable
# 	speed alterable
#
# 	mass ; invmass
#
#   ambient data
@icon("res://assets/art/icons/movement.png")
extends Resource
class_name MovementData

@export var mass : float = 1.0 : set = set_mass## kg
@export var ambient : AmbientData : set = set_ambient
## ambient is handling all the physical and movement data induced by the
## environment (for instance, max_speed, friction, base_accel, etc.).

var velocity : Vector2 = Vector2.ZERO ## pix/s
var invmass : float
var direction_pressed : Vector2 = Vector2.ZERO

var force_alterable = Alterable.new(Vector2.ZERO)
var speed_alterable = Alterable.new(Vector2.ZERO)
var accel_alterable = Alterable.new(Vector2.ZERO)

func set_mass(v : float):
	mass = v
	if v == 0.0:
		invmass = INF
	else:
		invmass = 1.0/mass

func set_ambient(_ambient : AmbientData):
	if ambient == _ambient:
		return
	ambient = _ambient
	# update base values for alterable:
	force_alterable.set_base_value(ambient.base_force)
	speed_alterable.set_base_value(ambient.base_speed)
	accel_alterable.set_base_value(ambient.base_accel)
