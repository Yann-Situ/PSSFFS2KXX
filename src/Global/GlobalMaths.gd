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
	#return lerp(velocity, 0.0, friction)
	return velocity*0.0 if friction >= 1.0 else velocity*exp(-(friction/(1-friction))*delta)

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

###############################################################################
## Balistic

## see https://www.desmos.com/calculator/7ad0ypexxd?lang=fr
## here is the general formula. Note that `eigen_distance` should be strictly positive
func shoot_velocity_formula(position:Vector2, eigen_distance:float=0.0, gravity:int=-1) -> Vector2:
	if position == Vector2.ZERO or eigen_distance <= 0:
		push_warning("non valid arguments: position="+str(position)+" eigen_distance="+str(eigen_distance))
		return Vector2.ZERO
	if gravity <= 0:
		gravity = Global.default_gravity.y
	var freq = sqrt(0.5 * abs(gravity) / eigen_distance)
	return Vector2(position.x*freq, position.y*freq-eigen_distance*freq)

func shoot_velocity_optimal(position:Vector2, gravity:int=-1) -> Vector2:
	return shoot_velocity_formula(position, position.length(), gravity)

## bell_ratio is equal to eigen_distance/position.length()
# bell_ratio > 1 gives a nice bell curve (higher curvature), whereas
# bell_ratio > 1 gives a straighter curve (lower curvature)
func shoot_velocity_bell_ratio(position:Vector2, bell_ratio:float = 1.0, gravity:int=-1) -> Vector2:
	return shoot_velocity_formula(position, bell_ratio * position.length(), gravity)
	
## eigen_distance from position and velocity formula.
# if the position is not reachable with velocity, then return -1.
func eigen_distance_from_velocity_formula(position:Vector2, velocity:Vector2, gravity:int=-1, s:float = 0.0) -> float:
	if gravity <= 0:
		gravity = Global.default_gravity.y
	var r = velocity.length_squared()/gravity + position.y #pix #\frac{r^{2}}{g}-D_{y}
	var delta = r*r - position.length_squared()
	if delta < 0:
		return -1
	return r + s * sqrt(delta)
		
## low eigen_distance (straight shoot) from position and velocity.
# if the position is not reachable with velocity, then return -1.
func eigen_distance_from_velocity_low(position:Vector2, velocity:Vector2, gravity:int=-1) -> float:
	return eigen_distance_from_velocity_formula(position, velocity, gravity, -1.0)

## high eigen_distance (loose shoot) from position and velocity.
# if the position is not reachable with velocity, then return -1.
func eigen_distance_from_velocity_high(position:Vector2, velocity:Vector2, gravity:int=-1) -> float:
	return eigen_distance_from_velocity_formula(position, velocity, gravity, +1.0)
	
## nice formula for shoot velocity for a straight shoot with minimal velocity and min bell_ratio
func shoot_velocity_straigt(position:Vector2, min_velocity:Vector2, bell_ratio:float = 1.0, gravity:int=-1) -> Vector2:
	if gravity <= 0:
		gravity = Global.default_gravity.y
	var eigen_dist = eigen_distance_from_velocity_low(position, min_velocity, gravity)
	if eigen_dist < 0.0: # if min_velocity is not enough
		return shoot_velocity_bell_ratio(position, bell_ratio, gravity)
	eigen_dist = min(eigen_dist, bell_ratio * position.length())
	return shoot_velocity_formula(position, eigen_dist, gravity)
