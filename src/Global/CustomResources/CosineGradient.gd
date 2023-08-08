extends ColorSampler
class_name CosineGradient

# check here for exploration http://dev.thi.ng/gradients/
@export var offset : Vector3 = Vector3(0.5,0.5,0.5)
@export var amplitude : Vector3 = Vector3(0.5,0.5,0.5)
@export var frequence : Vector3 = Vector3(1.0,1.0,1.0)
@export var phase : Vector3 = Vector3(0.0,0.33,0.66)

func sample(rng : RandomNumberGenerator, alpha : float = 1.0) -> Color:
	var c = color(rng.randf())
	c.a *= alpha
	return c

func color(t: float) -> Color:
	var c = Vector3.ZERO
	c.x = cos(6.28318*(frequence.x*t+phase.x))
	c.y = cos(6.28318*(frequence.y*t+phase.y))
	c.z = cos(6.28318*(frequence.z*t+phase.z))
	c = (offset + amplitude*c).clamp(Vector3.ZERO,Vector3.ONE)
	return Color(c.x,c.y,c.z,1.0)

func to_gradient(sampling_size : int = 0) -> Gradient:
	if sampling_size <= 1:
		sampling_size = 18*int(frequence[frequence.max_axis_index()])
	var g = Gradient.new()
	g.remove_point(0)
	g.remove_point(0)
	for i in range(sampling_size):
		var t = float(i)/sampling_size
		g.add_point(t, color(t))
	return g

# skin1 : [[1.100 0.450 0.110] [0.740 0.470 0.650] [0.590 0.500 0.320] [1.925 0.880 -0.022]]
