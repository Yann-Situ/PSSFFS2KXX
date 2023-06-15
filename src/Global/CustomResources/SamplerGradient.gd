extends ColorSampler
class_name SamplerGradient

# check here for exploration http://dev.thi.ng/gradients/
@export var gradient : Gradient

func sample(rng : RandomNumberGenerator, alpha : float = 1.0) -> Color:
	var c = gradient.sample(rng.randf())
	c.a *= alpha
	return c
