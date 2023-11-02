@icon("res://assets/art/icons/color-circle.png")
extends Resource
class_name ColorSampler

@export var weight : float = 1.0 # use for unions

func sample(rng : RandomNumberGenerator, alpha : float = 1.0) -> Color:
	return Color(rng.randf(),rng.randf(),rng.randf(),alpha)
