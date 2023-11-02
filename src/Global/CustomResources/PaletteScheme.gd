@icon("res://assets/art/icons/palette-gradient.png")
extends Resource
class_name PaletteScheme
## Just contain a list of gradients. Often dark-to-light gradients to colorize
## sprites with a palette.
var gradients = [] # (Array, Gradient)

func size() -> int:
	return gradients.size()

func get_gradient(i : int) -> Gradient:
	if i < gradients.size() and i >= 0:
		return gradients[i]
	push_warning("out of bounds, return default gradient")
	return Gradient.new()

func clear_gradients():
	gradients.clear()

func add_gradient(gradient : Gradient, index : int = -1):
	if index == -1:
		gradients.push_back(gradient)
	else :
		gradients.insert(index, gradient)

func add_cosine_gradient(cosine_gradient : CosineGradient, index : int = -1):
	add_gradient(cosine_gradient.to_gradient(), index)

func remove_gradient(index : int):
	gradients.remove_at(index)

################################################################################
func get_lightness(c : Color) -> float:
	return 0.2076*c.r + 0.7002*c.g + 0.0922*c.b

func add_gradient_from_color(color : Color,\
		black : Color=Color.BLACK, white : Color=Color.WHITE):
	var g = Gradient.new()
	var l = get_lightness(color)
	var lw = get_lightness(white)
	var lb = get_lightness(black)
	if lw < lb: # swap variables
		var lb_s = lb
		var black_s = black
		lb = lw
		black = white # hashtag everybody equal hashtag mum and dad
		lw = lb_s
		white = black_s

	if lw < l and l > 0.0:
		var t = lw/l
		color =  Color(t*color.r, t*color.g, t*color.b)
		l = lw
	elif lb > l and l > 0.0:
		var t = lb/l
		color =  Color(t*color.r, t*color.g, t*color.b)
		l = lb
	l = inverse_lerp(lb,lw,l)

	if l > 0.5:
		g.set_color(0, black.lerp(white, l-0.5))
		g.add_point(1.5-l,white)
	else:
		g.set_color(1, black.lerp(white, 0.5+l))
		g.add_point(0.5-l,black)
	g.add_point(0.5, color)
	gradients.push_back(g)

func add_gradient_from_colors(colors : PackedColorArray):
	if colors.size() < 2:
		push_warning("gradient with less than 2 colors")
		return
	var g = Gradient.new()
	g.set_colors(colors)
	var offset = 0.0
	var step = 1.0/colors.size()
	for i in range(colors.size()):
		g.set_offset(i,offset)
		offset += step
	gradients.push_back(g)

func display():
	var s = ""
	for gradient in gradients:
		s+= ("[")
		for i in [0.5]:
			s+=(str(gradient.sample(i)))
		s+=("]\n")
	print(s)
