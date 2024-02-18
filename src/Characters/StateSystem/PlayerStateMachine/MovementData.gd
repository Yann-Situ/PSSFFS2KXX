## MovementData:
# should store:
#	velocity
#
# 	acceleration alterer
# 	force alterer
# 	speed alterer
#
# 	mass ; invmass
#   time_scale
#
# 	side_speed_max
# 	side_instant_speed
# 	side_instant_speed_return_thresh
# 	side_accel
#
# 	friction

#@icon("res://assets/art/icons/hexagon-beige.png")
extends Resource
class_name MovementData

@export var mass : float = 1.0 # kg
var invmass : float

@export var velocity : Vector2 = Vector2.ZERO # pix/s
@export var friction : Vector2 = Vector2(0.25, 0.9) # ?
@export var time_scale : float = 1.0 # s/s

@export_group("Side movement", "side_")
@export var side_speed_max : float = 300.0 # pix/s
@export var side_instant_speed : float = 25.0 # pix/s
@export var side_instant_speed_return_thresh : float = 10.0 # pix/s
@export var side_accel : float = 50.0 # pix/s2

var force_alterable = Alterable.new(Vector2.ZERO)
var speed_alterable = Alterable.new(Vector2.ZERO)
var accel_alterable = Alterable.new(Vector2.ZERO)

# TEMPORARY for test
func _init():
	invmass = 1.0/mass
	accel_alterable.add_alterer(Global.gravity_alterer)

# WARNING: infinite recursion
# func modification(modifier : MovementDataModifer) -> MovementData:
# 	return modifier.apply(self)
