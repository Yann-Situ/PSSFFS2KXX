extends Resource
class_name AmbientDataScaler

@export var friction : float = 1.0
@export var time_scale : float = 1.0

@export_group("Side movement", "side_")
@export var side_speed_max : float = 1.0
@export var side_instant_speed : float = 1.0
@export var side_instant_speed_return_thresh : float = 1.0
@export var side_accel : float = 1.0

@export var base_force : float = 1.0
@export var base_accel : float = 1.0
@export var base_speed : float = 1.0

func apply(ambient_data : AmbientData) -> AmbientData:
	# ambient_data will be duplicated:
	var ad = ambient_data.duplicate(false)
	ad.friction *= friction
	ad.time_scale *= time_scale
	ad.side_speed_max *= side_speed_max
	ad.side_instant_speed *= side_instant_speed
	ad.side_instant_speed_return_thresh *= side_instant_speed_return_thresh
	ad.side_accel *= side_accel
	ad.base_force *= base_force
	ad.base_accel *= base_accel
	ad.base_speed *= base_speed
	return ad
