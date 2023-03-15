extends Resource
class_name ColorSampler

@export var hue_distribution : Curve : set = set_hue_distribution
@export var saturation_distribution : Curve : set = set_saturation_distribution
@export var lightness_distribution : Curve : set = set_lightness_distribution

var hue_sampler = Curve.new()
var saturation_sampler = Curve.new()
var lightness_sampler = Curve.new()

func set_hue_distribution(c : Curve):
	hue_distribution = c
	hue_sampler = compute_sampler(hue_distribution)
	# print("Color sampler changed")
	# for i in range(6):
	# 	print(str(hue_sampler.sample_baked(i/5.0)))
	emit_changed()
func set_saturation_distribution(c : Curve):
	saturation_distribution = c
	saturation_sampler = compute_sampler(saturation_distribution)
	# print("Color sampler changed")
	# for i in range(6):
	# 	print(str(saturation_sampler.sample_baked(i/5.0)))
	emit_changed()
func set_lightness_distribution(c : Curve):
	lightness_distribution = c
	lightness_sampler = compute_sampler(lightness_distribution)
	# print("Color sampler changed")
	# for i in range(6):
	# 	print(str(lightness_sampler.sample_baked(i/5.0)))
	emit_changed()

func compute_sampler(distribution : Curve) -> Curve:
	var sampler = Curve.new()
	var integral = []
	var n = distribution.bake_resolution
	if n < 2:
		push_error("distribution.bake_resolution below 2")
		return sampler

	# integration with trapeze method
	var inv_n = 1.0/n
	var s = 0.5 * distribution.sample_baked(0.0)
	integral.push_back(s)
	distribution.bake()
	for i in range(1,n-1):
		s += distribution.sample_baked(i*inv_n)
		integral.push_back(s)
	s += 0.5 * distribution.sample_baked(1.0)
	integral.push_back(s)

	# invert integral
	assert(s != 0.0)
	var last_x = -1
	for i in range(n):
		var p = Vector2(integral[i]/s, i*inv_n)
		# if i%20 == 0:
		# 	print(p)
		if last_x < p.x:
			sampler.add_point(p, 0, 0, Curve.TANGENT_LINEAR,Curve.TANGENT_LINEAR)
			last_x = p.x
	#sampler.clean_dupes()
	sampler.bake()
	return sampler

func update_samplers():
	hue_sampler = compute_sampler(hue_distribution)
	saturation_sampler = compute_sampler(saturation_distribution)
	lightness_sampler = compute_sampler(lightness_distribution)

# sample a color following the sampler. if sh (resp. ss, sv) is not in [0,1], use randf instead
func sample(rng : RandomNumberGenerator, alpha : float = 1.0) -> Color:
	var h = hue_sampler.sample_baked(rng.randf())
	var s = saturation_sampler.sample_baked(rng.randf())
	var l = lightness_sampler.sample_baked(rng.randf())

	var t = min(l,1-l)
	var v = l + s*t
	if v == 0:
		s = 0
	else :
		s = 2*(1-l/v)
	#print("sample "+str(Color().from_hsv(h,s,v,alpha)))
	return Color().from_hsv(h,s,v,alpha)
