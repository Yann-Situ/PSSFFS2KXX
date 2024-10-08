extends Node2D

@export var P: OldPlayer
@onready var S = P.get_state_node()

var points = Array()
@export var nb_points_display : int = 50
@export var coeff_display : int = 6
var nb_points = coeff_display * nb_points_display
@export var delta : float = .03 / coeff_display

# Shoot features
@export var shoot_min_speed : float = 100 # kg*pix/s
@export var shoot_speed_max : float = 600 # kg*pix/s
@export var shoot_max_aim_time : float = 1 # s
var shoot_vector_save = Vector2()

const white = Color(1,1,1,1)
const red = Color(1,0,0,1)
const yellorange = Color.DEEP_PINK

@export var flip_h : bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func shoot_vector(): # return shoot vector if player not moving
	var t = S.time-S.last_aim_jp
	t = min(shoot_max_aim_time, t)/shoot_max_aim_time
	t = shoot_min_speed+t*(shoot_speed_max-shoot_min_speed)
	if S.active_ball != null: # to be sure
		t = t/S.active_ball.mass
	return t * (Global.camera.get_global_mouse_position() -
					P.position).normalized()

func _draw():
	for i in range(0, points.size() - 1, coeff_display):
		#draw_line(points[i], points[i+1], red, 1)
		draw_circle(points[i], 2, yellorange)

func draw_prediction(_position, vel, grav):
	points.clear()
	for i in range(nb_points):
		points.append(_position)
		vel += 1.0*grav * delta
		_position += 1.0*vel * delta + 0.5 * grav*delta*delta # Thanks Taylor
	queue_redraw()

func draw_attract(initial_position, vel, grav, power):
	points.clear()
	var pos_init = initial_position
	for i in range(nb_points):
		points.append(initial_position)
		vel += (1.002*grav + 1.002*power * (pos_init-initial_position).normalized()) * delta
		position += 0.998*vel * delta
	queue_redraw()

func clear():
	points.clear()
	queue_redraw()

func set_flip_h(b):
	flip_h = b
