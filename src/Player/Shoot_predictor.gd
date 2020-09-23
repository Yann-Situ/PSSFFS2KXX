extends Node2D

var points = Array()
export (int) var nb_points = 50
export (float) var delta = .05
	
var white = Color(1,1,1,1)
var red = Color(1,0,0,1)

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
