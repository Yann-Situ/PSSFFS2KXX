extends ColorSampler
class_name ColorSamplerUnion

# check here for exploration http://dev.thi.ng/gradients/
@export var color_samplers : Array[ColorSampler]

func sample(rng : RandomNumberGenerator, alpha : float = 1.0) -> Color:
	var total_weight = 0.0
	for sampler in color_samplers:
		total_weight += sampler.weight
	var t = rng.randf()*total_weight

	total_weight = 0.0
	for sampler in color_samplers:
		if t <= total_weight + sampler.weight:
			return sampler.sample(rng, alpha)
		total_weight += sampler.weight
	push_error("should not be possible to reach this point, but we never know with float issues")
	return Color()
