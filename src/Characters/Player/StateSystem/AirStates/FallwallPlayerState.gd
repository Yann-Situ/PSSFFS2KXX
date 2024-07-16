extends PlayerMovementState

@export var ambient_modifier : AmbientDataScaler ## ambient modifier, to slow the acceleration during crouch
#need to handle hit/collision box resizing + crouch parameters + jump

@export_group("States")
@export var belong_state : State
@export var action_state : State
@export var land_state : State
@export var fall_state : State
@export var walljump_state : State

# var belong : Status = Status.new(["belong"]) # appropriate declaration
# var action : Status = Status.new(["belong"]) # appropriate declaration
# var floor : Status = Status.new(["belong"]) # appropriate declaration
# var wall : Status = Status.new(["belong"]) # appropriate declaration

func _ready():
	animation_variations = [["air_wall"]]

func branch() -> State:
	if logic.belong_ing:
		return belong_state
	if logic.action.can:
		return action_state

	if logic.walljump.can and !logic.jump_press_timer.is_stopped():
		#logic.floor.ing = false # TEMPORARY solution to avoid infinite recursion
		return walljump_state
	if logic.floor.ing:
		return land_state
	if !logic.wall.ing:
		return fall_state
	return self

# func animation_process() -> void:
# 	pass

## Called by the parent StateMachine during the _physics_process call, after
## the StatusLogic physics_process call.
func physics_process(delta) -> State:
	var next_state = branch()
	if next_state != self:
		return next_state

	var m : MovementData = movement.duplicate_with_ambient_scaler(ambient_modifier)
	side_move_physics_process(delta, m)

	# update player position
	if player.physics_enabled:
		# using wall version of physics 
		wall_movement_physics_process(delta, m)

	# TODO : weird handling of velocity due to being inside movementdata:
	movement.velocity = m.velocity
	return self

## call player.move_and_slide() and update m.velocity
# modification for fallwall to apply vertical friction even if up is not pressed
func wall_movement_physics_process(delta, m : MovementData = movement):
	delta *= m.ambient.time_scale

	# apply alterables
	apply_force_alterable(delta, m)
	apply_accel_alterable(delta, m)

	# friction
	if logic.side.can and logic.friction.can and sign(m.velocity.x) != sign(m.direction_pressed.x):
		m.velocity.x = GlobalMaths.apply_friction(m.velocity.x, m.ambient.friction.x, delta)
	## About vertical friction for fallwall:
	# we want friction when falling so:
	if logic.friction.can and m.velocity.y > 0:
		m.velocity.y = GlobalMaths.apply_friction(m.velocity.y, m.ambient.friction.y, delta)

	# move and slide
	apply_speed_alterable(delta, m)
	player.set_velocity(m.velocity)
	player.move_and_slide()	# update player position
	## TODO think about those two alternatives: get_velocity seems to be working well with moving platform and slopes
	#m.velocity = player.get_real_velocity()-m.speed_alterable.get_value() 
	m.velocity = player.get_velocity()-m.speed_alterable.get_value()
