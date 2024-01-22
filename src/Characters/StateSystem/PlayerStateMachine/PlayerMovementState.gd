extends PlayerState
class_name PlayerMovementState

@onready var movement : MovementData = player.movement ## Player movement Resource, or node

func side_move_physics_process(delta):
	if logic.direction_pressed.x == 0.0:
		return
	if -movement.side_instant_speed_return_thresh < movement.velocity.x*logic.direction_pressed.x \
		and movement.velocity.x*logic.direction_pressed.x < movement.side_instant_speed :
		movement.velocity.x = logic.direction_pressed.x*movement.side_instant_speed
	if (movement.velocity.x*logic.direction_pressed.x >= movement.side_speed_max) :
		pass # in the same logic.direction_pressed.x as velocity and faster than max
	else :
		movement.velocity.x += logic.direction_pressed.x*movement.side_accel*delta
		if (movement.velocity.x*logic.direction_pressed.x > movement.side_speed_max) :
			movement.velocity.x = logic.direction_pressed.x*movement.side_speed_max

func movement_physics_process(delta):
	# TODO player movement:
	delta *= movement.time_scale

	# charcter held is not treated here
	# if character_holder != null:
	# 	if character_holder.has_method("move_character"):
	# 		apply_forces_accel(delta)
	# 		#set_velocity(S.velocity+speed_alterable.get_value())
	# 		S.velocity = character_holder.move_character(self, S.velocity+speed_alterable.get_value(), delta)
	# 		S.velocity -= speed_alterable.get_value()

	var force = movement.force_alterable.get_value()
	movement.velocity += movement.invmass * delta * force
	var accel = movement.accel_alterable.get_value()
	movement.velocity += delta * accel
	# if S.is_onwall and S.velocity.y > 0.0: #fall on a wall
	# 	S.velocity.y = min(S.velocity.y,fall_speed_max_onwall)
	# else :
	# 	S.velocity.y = min(S.velocity.y,fall_speed_max)
	# movement.velocity.y = min(movement.velocity.y, movement.fall_speed_max)
	# # TODO do I clamp this value, or let the friction do this effect?
	# maybe just clamp the velocity norm instead of the y direction only

	# handle friction
	if sign(movement.velocity.x) != sign(logic.direction_pressed.x): # if not moving in the same dir as input # TODO handle logic.direction_pressed.x
		movement.velocity.x = GlobalMaths.apply_friction(movement.velocity.x, movement.friction.x, delta)
	if sign(movement.velocity.y) != sign(logic.direction_pressed.y): # if not moving in the same dir as input # TODO handle logic.direction_pressed.x
		movement.velocity.y = GlobalMaths.apply_friction(movement.velocity.y, movement.friction.y, delta)

	player.set_velocity(movement.velocity+movement.speed_alterable.get_value())
	player.move_and_slide()
	movement.velocity = player.get_real_velocity()-movement.speed_alterable.get_value()

func physics_process(delta) -> State:
	var next_state = branch()
	if next_state != self:
		return next_state

	if player.physics_enabled:
		movement_physics_process(delta)
	return self
