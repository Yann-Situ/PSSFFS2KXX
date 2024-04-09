## TestMovementDataModifer:
# should store float for:
#	mass
#   time_scale
# 	side_speed_max
# 	side_instant_speed
# 	side_instant_speed_return_thresh
# 	side_accel
# 	friction

extends Resource
class_name TestMovementDataModifier

@export var mass : float = 1.0
@export var friction : float = 1.0
@export var time_scale : float = 1.0

@export_group("Side movement", "side_")
@export var side_speed_max : float = 1.0
@export var side_instant_speed : float = 1.0
@export var side_instant_speed_return_thresh : float = 1.0
@export var side_accel : float = 1.0

func apply(m : TestMovementData) -> TestMovementData:
	# nested subresources will be shared:
	var mr = m.duplicate(false)
	mr.mass *= mass
	mr.friction *= friction
	mr.time_scale *= time_scale
	mr.side_speed_max *= side_speed_max
	mr.side_instant_speed *= side_instant_speed
	mr.side_instant_speed_return_thresh *= side_instant_speed_return_thresh
	mr.side_accel *= side_accel
	return mr
