extends Resource
class_name PaletteSchemeSampler

export (Array, Resource) var color_samplers
export (Color) var black = ColorN("black")
export (Color) var white = ColorN("white")

func sample(rng : RandomNumberGenerator) -> PaletteScheme:
	var p = PaletteScheme.new()
	for color_sampler in color_samplers:
		p.add_gradient_from_color(color_sampler.sample(rng), black, white)
	return p