tool
extends Path2D

export(float, -8.0, 8.0) var p0_slope = 0.0 setget set_slope # pix/pix
export(int, 2, 1024) var nb_line_points = 30

## aza
export(float,1.0, 10.0) var line_width setget set_width # pix/pix
export(Color, RGBA) var line_modulate setget set_line_modulate
export(Texture) var line_texture setget set_texture

var p0 : Vector2 # first end point
var p1 : Vector2 # second end point (p0.x <= p1.x)
onready var line : Line2D = $Line2D 

# the parabola is parametrised as follows: y = k(x - pmin.x)^2 + pmin.y
var pmin : Vector2
var k : float # pix-1

func set_slope(slope : float):
	p0_slope = slope
	if line != null:
		update_catenary()

func set_width(w : float):
	line_width = w
	if line != null:
		line.width = line_width
		update_catenary()

func set_line_modulate(col : Color):
	line_modulate = col
	if line != null:
		line.modulate = line_modulate
		update_catenary()
	
func set_texture(texture : Texture):
	line_texture = texture
	if line != null and texture != null:
		line.texture = line_texture
		update_catenary()

################################################################################
func _ready():
	set_slope(p0_slope)
	set_width(line_width)
	set_line_modulate(line_modulate)
	set_texture(line_texture)

func update_catenary():
	update_endpoints()
	compute_parabola_parameters()
	update_Line2D_points()

func update_endpoints():
	# also ensure p0.x <= p1.x
	p0 = self.curve.get_point_position(0)
	p1 = self.curve.get_point_position(1)
	if p0.x > p1.x:
		var temp = p1
		p1 = p0
		p0 = temp

func compute_parabola_parameters() -> bool:
	# compute pmin and k: the parabola is parametrised as : y = k(x - pmin.x)^2 + pmin.y
	# return if the parameters are valid
	var H = p1.y - p0.y
	var L = p1.x - p0.x
	if L == 0.0:
		push_warning("ParabolaCatenary invalid parameters")
		return false
	var invL = 1.0/L
	var kL = H*invL - p0_slope
	if kL == 0.0:
		push_warning("ParabolaCatenary invalid parameters")
		return false
	k = kL*invL
	var H_above_KL = H/kL
	pmin.x = 0.5*(p1.x + p0.x - H_above_KL)
	var temp = 0.5*(H_above_KL - L)
	pmin.y = p0.y - k*temp*temp
	return true

func parabola(x : float):
	var temp = (x - pmin.x)
	return k*temp*temp + pmin.y

func update_Line2D_points():
	# update the Line2D points
	line.clear_points()
	var p = p0
	line.add_point(p)
	var increment = (p1.x - p0.x)/nb_line_points
	for i in range(nb_line_points):
		p.x = p.x + increment
		p.y = parabola(p.x)
		line.add_point(p)
