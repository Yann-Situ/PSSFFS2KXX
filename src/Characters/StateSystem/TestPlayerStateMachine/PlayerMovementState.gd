extends TestPlayerState
class_name TestPlayerMovementState

@onready var movement : MovementData = player.movement ## Player movement Resource, or node

func side_move_physics_process(delta, m : MovementData = movement):
	if logic.direction_pressed.x == 0.0:
		return
	if -m.side_instant_speed_return_thresh < m.velocity.x*logic.direction_pressed.x \
		and m.velocity.x*logic.direction_pressed.x < m.side_instant_speed :
		m.velocity.x = logic.direction_pressed.x*m.side_instant_speed
	if (m.velocity.x*logic.direction_pressed.x >= m.side_speed_max) :
		pass # in the same logic.direction_pressed.x as velocity and faster than max
	else :
		m.velocity.x += logic.direction_pressed.x*m.side_accel*delta
		if (m.velocity.x*logic.direction_pressed.x > m.side_speed_max) :
			m.velocity.x = logic.direction_pressed.x*m.side_speed_max

func movement_physics_process(delta, m : MovementData = movement):
	# TODO player movement:
	delta *= m.time_scale

	# charcter held is not treated here
	# if character_holder != null:
	# 	if character_holder.has_method(["move_character"]):
	# 		apply_forces_accel(delta)
	# 		#set_velocity(S.velocity+speed_alterable.get_value())
	# 		S.velocity = character_holder.move_character(self, S.velocity+speed_alterable.get_value(), delta)
	# 		S.velocity -= speed_alterable.get_value()

	var force = m.force_alterable.get_value()
	m.velocity += m.invmass * delta * force
	var accel = m.accel_alterable.get_value()
	m.velocity += delta * accel
	# if S.is_onwall and S.velocity.y > 0.0: #fall on a wall
	# 	S.velocity.y = min(S.velocity.y,fall_speed_max_onwall)
	# else :
	# 	S.velocity.y = min(S.velocity.y,fall_speed_max)
	# m.velocity.y = min(m.velocity.y, m.fall_speed_max)
	# # TODO do I clamp this value, or let the friction do this effect?
	# maybe just clamp the velocity norm instead of the y direction only

	# handle friction
	if sign(m.velocity.x) != sign(logic.direction_pressed.x): # if not moving in the same dir as input # TODO handle logic.direction_pressed.x
		m.velocity.x = GlobalMaths.apply_friction(m.velocity.x, m.friction.x, delta)
	if sign(m.velocity.y) != sign(logic.direction_pressed.y): # if not moving in the same dir as input # TODO handle logic.direction_pressed.x
		m.velocity.y = GlobalMaths.apply_friction(m.velocity.y, m.friction.y, delta)

	player.set_velocity(m.velocity+m.speed_alterable.get_value())
	player.move_and_slide()
	m.velocity = player.get_real_velocity()-m.speed_alterable.get_value()

func physics_process(delta) -> State:
	var next_state = branch()
	if next_state != self:
		return next_state

	if player.physics_enabled:
		movement_physics_process(delta)
	return self
