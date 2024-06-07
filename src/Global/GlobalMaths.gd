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
	return lerp(velocity, 0.0, friction)
#	var friction_pow_delta = 0.0 if friction >= 1.0 else pow(1.0-friction, delta)
#	return velocity*friction_pow_delta
# works for flat and vector2

## the polar coordinates are given as (radius, theta)
func polar_to_cartesian(c : Vector2) -> Vector2:
	return c.x * Vector2(cos(c.y), sin(c.y))

## return the dash_velocity Vector2, taking into account the target_velocity
func anticipate_dash_velocity(current_position : Vector2, target_position : Vector2,
	current_velocity : Vector2 = Vector2.ZERO, target_velocity : Vector2 = Vector2.ZERO,
	dunkdash_speed : float = 0.0) -> Vector2:
	var q = (target_position - current_position)
	var ql = q.length()
	var target_dir = Vector2.UP # limit case when the player is exactly on the target
	if ql != 0.0:
		target_dir = 1.0/ql * q
	var dash_speed = max(dunkdash_speed, current_velocity.dot(target_dir))
	var anticipated_position = target_position + ql/dash_speed * target_velocity
	return dash_speed * (anticipated_position - current_position).normalized()
