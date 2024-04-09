## AmbientData:
# should store:
#	acceleration
# 	force
# 	speed
#
# 	time_scale
#
# 	side_speed_max
# 	side_instant_speed
# 	side_instant_speed_return_thresh
# 	side_accel
#
# 	friction

#@icon("res://assets/art/icons/hexagon-beige.png")
extends Resource
class_name AmbientData

@export var friction : Vector2 = Vector2(0.25, 0.9)
## friction.x and friction.y are respectively horizontal and vertical friction
@export var time_scale : float = 1.0 ## s/s

@export_group("Side movement", "side_")
@export var side_speed_max : float = 300.0 ## pix/s
@export var side_instant_speed : float = 25.0 ## pix/s
@export var side_instant_speed_return_thresh : float = 10.0 ## pix/s
@export var side_accel : float = 50.0 ## pix/s2

@export var base_force : Vector2 = Vector2.ZERO : set = set_force
@export var base_accel : Vector2 = Vector2.ZERO : set = set_accel
@export var base_speed : Vector2 = Vector2.ZERO : set = set_speed
## the base value that is setup for the player
func set_force(v : Vector2) -> void:
	base_force = v
	emit_changed()
## the base value that is setup for the player
func set_accel(v : Vector2) -> void:
	base_accel = v
	emit_changed()
## the base value that is setup for the player
func set_speed(v : Vector2) -> void:
	base_speed = v
	emit_changed()
