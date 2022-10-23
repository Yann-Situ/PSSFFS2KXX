extends Resource
class_name PaletteScheme

export (Array, Gradient) var gradients = []

func display():
	var s = ""
	for gradient in gradients:
		s+= ("[")
		for i in [0.5]:
			s+=(str(gradient.interpolate(i)))
		s+=("]\n")
	print(s)

func clear_gradients():
	gradients.clear()

func add_gradient_from_color(color : Color,\
		black : Color=ColorN("black"), white : Color=ColorN("white")):
	var g = Gradient.new()
	g.set_color(0,black)
	g.set_color(1,white)
	g.add_point(0.5, color)
	#g.set_local_to_scene(true) ?
	gradients.push_back(g)

func add_gradient_from_colors(colors : PoolColorArray):
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
