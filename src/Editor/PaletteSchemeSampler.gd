extends Resource
class_name PaletteSchemeSampler

@export var color_samplers : Array[Resource]
@export var black : Color = ColorN("black")
@export var white : Color = ColorN("white")

func sample(rng : RandomNumberGenerator) -> PaletteScheme:
	var p = PaletteScheme.new()
	for color_sampler in color_samplers:
		p.add_gradient_from_color(color_sampler.sample(rng), black, white)
	return p
