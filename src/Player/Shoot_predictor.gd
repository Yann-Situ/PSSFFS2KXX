extends Node2D

onready var Player = get_parent().get_parent()
onready var S = Player.get_node("Player_State")

var points = Array()
export (int) var nb_points_display = 50
export (int) var coeff_display = 6
var nb_points = coeff_display * nb_points_display
export (float) var delta = .03 / coeff_display

# Shoot features
export (float) var shoot_min_speed = 100 # kg*pix/s
export (float) var shoot_max_speed = 600 # kg*pix/s
export (float) var shoot_max_aim_time = 1 # s
var shoot_vector_save = Vector2()

var white = Color(1,1,1,1)
var red = Color(1,0,0,1)
var yellorange = Color(1.0,0.8,0.1,1)

export (bool) var flip_h = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func shoot_vector(): # return shoot vector if player not moving
	var t = S.time-S.last_aim_jp
	t = min(shoot_max_aim_time, t)/shoot_max_aim_time
	t = shoot_min_speed+t*(shoot_max_speed-shoot_min_speed)
	if S.active_ball != null: # to be sure
		t = t/S.active_ball.mass
	return t * (Player.get_node("Camera").get_global_mouse_position() - 
					Player.position).normalized()

func _draw():
	for i in range(0, points.size() - 1, coeff_display):
		#draw_line(points[i], points[i+1], red, 1)
		draw_circle(points[i], 2, yellorange)
		
func draw(pos, vel, grav):
	points.clear()
	for i in range(nb_points):
		points.append(pos)
		vel += 1.002*grav * delta
		pos += 0.998*vel * delta
	update()

func draw_attract(pos, vel, grav, power):
	points.clear()
	var pos_init = pos
	for i in range(nb_points):
		points.append(pos)
		vel += (1.002*grav + 1.002*power * (pos_init-pos).normalized()) * delta
		pos += 0.998*vel * delta
	update()
	
func clear():
	points.clear()
	update()

func set_flip_h(b):
	flip_h = b
