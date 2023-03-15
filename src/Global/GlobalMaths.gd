extends Node

func get_max_radius(s : Shape2D):
	if s is CircleShape2D:
		return s.radius
	elif s is CapsuleShape2D:
		return s.height
	elif s is RectangleShape2D:
		return max(s.size.x, s.size.y)
	elif s is SeparationRayShape2D:
		return s.length
	elif s is SegmentShape2D:
		return 0.5*(s.A-s.B).length()
	elif s is WorldBoundaryShape2D:
		return INF
	else:
		push_warning("this Shape2D is not handled for max_radius, returning 0.0.")
		return 0.0

func unfriction_to_friction(unfriction : float) -> float:
	#unfriction is the time it takes (in s) to divide speed by ten
	if unfriction <= 0.0:
		return 1.0
	elif unfriction == INF:
		return 0.0
	return 1.0-pow(0.1, 1.0/unfriction)

func apply_friction(velocity, friction : float, delta : float):
	var friction_pow_delta = 0.0 if friction >= 1.0 else pow(1.0-friction, delta)
	return velocity*friction_pow_delta
# works for flat and vector2
