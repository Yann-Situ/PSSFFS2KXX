extends Node2D

var points = Array()
export (int) var nb_points = 50
export (float) var delta = .05

# Shoot features
export (float) var shoot_min_speed = 100 # pix/s
export (float) var shoot_max_speed = 600 # pix/s
export (float) var shoot_max_aim_time = 1000 # ms
var shoot_vector_save = Vector2()

var white = Color(1,1,1,1)
var red = Color(1,0,0,1)

var S
# Called when the node enters the scene tree for the first time.
func _ready():
	S = get_parent().get_node("Player_State")

func shoot_vector(): # return shoot vector if player not moving
	var t = S.time-S.last_aim_jp
	t = min(shoot_max_aim_time, t)/shoot_max_aim_time
	t = shoot_min_speed+t*(shoot_max_speed-shoot_min_speed)
	if S.active_ball != null: # to be sure
		t = t/S.active_ball.mass
	return t * (get_parent().get_node("Camera").get_global_mouse_position() - 
					get_parent().position).normalized()

func _draw():
	for i in range(0, points.size() - 1):
		#draw_line(points[i], points[i+1], red, 1)
		draw_circle(points[i], 1, white)
		
func draw(pos, vel, grav):
	points.clear()
	for i in range(nb_points):
		points.append(pos)
		vel += grav * delta
		vel.x *= .999
		vel.y *= .991
		pos += vel * delta
	update()
	
	
func clear():
	points.clear()
	update()
