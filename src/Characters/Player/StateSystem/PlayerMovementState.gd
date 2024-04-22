extends PlayerState
class_name PlayerMovementState

@onready var movement : MovementData = player.movement ## Player movement Resource, or node

func side_move_physics_process(delta, m : MovementData = movement):
	if m.direction_pressed.x == 0.0:
		return
	if -m.ambient.side_instant_speed_return_thresh < m.velocity.x*m.direction_pressed.x \
		and m.velocity.x*m.direction_pressed.x < m.ambient.side_instant_speed :
		m.velocity.x = m.direction_pressed.x*m.ambient.side_instant_speed
	if (m.velocity.x*m.direction_pressed.x >= m.ambient.side_speed_max) :
		pass # in the same m.direction_pressed.x as velocity and faster than max
	else :
		m.velocity.x += m.direction_pressed.x * m.ambient.side_accel * \
			delta * m.ambient.time_scale
		if (m.velocity.x*m.direction_pressed.x > m.ambient.side_speed_max) :
			m.velocity.x = m.direction_pressed.x*m.ambient.side_speed_max

## call player.move_and_slide() and update m.velocity
func movement_physics_process(delta, m : MovementData = movement):
	delta *= m.ambient.time_scale

	# apply alterables
	apply_force_alterable(delta, m)
	apply_accel_alterable(delta, m)

	# friction
	if sign(m.velocity.x) != sign(m.direction_pressed.x): # if not moving in the same dir as input # TODO handle m.direction_pressed.x
		m.velocity.x = GlobalMaths.apply_friction(m.velocity.x, m.ambient.friction.x, delta)
	if sign(m.velocity.y) != sign(m.direction_pressed.y): # if not moving in the same dir as input # TODO handle m.direction_pressed.x
		m.velocity.y = GlobalMaths.apply_friction(m.velocity.y, m.ambient.friction.y, delta)

	# move and slide
	apply_speed_alterable(delta, m)
	player.set_velocity(m.velocity)
	player.move_and_slide()	# update player position
	m.velocity = player.get_real_velocity()-m.speed_alterable.get_value()

## WARNING this function doesn't multiply delta by time_scale, as it is meant to be used in movement_physics_process
func apply_force_alterable(scaled_delta, m : MovementData = movement):
	m.velocity += m.invmass * scaled_delta * m.force_alterable.get_value()

## WARNING this function doesn't multiply delta by time_scale, as it is meant to be used in movement_physics_process
func apply_accel_alterable(scaled_delta, m : MovementData = movement):
	m.velocity += scaled_delta * m.accel_alterable.get_value()

func apply_speed_alterable(scaled_delta, m : MovementData = movement):
	m.velocity += m.speed_alterable.get_value()

################################################################################

func physics_process(delta) -> State:
	var next_state = branch()
	if next_state != self:
		return next_state
	side_move_physics_process(delta)
	if player.physics_enabled:
		movement_physics_process(delta, movement)
	return self
