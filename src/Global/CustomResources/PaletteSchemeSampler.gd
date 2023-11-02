@icon("res://assets/art/icons/palette.png")
extends Resource
class_name PaletteSchemeSampler

@export var color_samplers : Array[ColorSampler]
@export var black : Color = Color.BLACK
@export var white : Color = Color.WHITE

func sample(rng : RandomNumberGenerator) -> PaletteScheme:
	var p = PaletteScheme.new()
	for color_sampler in color_samplers:
		p.add_gradient_from_color(color_sampler.sample(rng), black, white)
	return p
