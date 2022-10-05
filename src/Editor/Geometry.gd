tool
extends Node

func get_max_radius(s : Shape2D):
	if s is CircleShape2D:
		return s.radius
	elif s is CapsuleShape2D:
		return s.height
	elif s is RectangleShape2D:
		return max(s.extents.x, s.extents.y)
	elif s is RayShape2D:
		return s.length
	elif s is SegmentShape2D:
		return 0.5*(s.A-s.B).length()
	elif s is LineShape2D:
		return INF
	else:
		push_warning("this Shape2D is not handled for max_radius, returning 0.0.")
		return 0.0
