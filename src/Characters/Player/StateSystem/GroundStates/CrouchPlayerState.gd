extends PlayerMovementState

@export var ambient_modifier : AmbientDataScaler ## ambient modifier, to slow the acceleration during crouch
#need to handle hit/collision box resizing + crouch parameters + jump

@export_group("States")
@export var belong_state : State
@export var action_state : State
@export var fall_state : State
@export var stand_state : State

func _ready():
	animation_variations = [["crouch_idle"], ["crouch"]]
	assert(ambient_modifier != null)

func branch() -> State:
	if logic.belong.ing:
		return belong_state
	if logic.action.can:
		return action_state
	if !logic.floor.ing:
		return fall_state

	if logic.stand.can and !logic.down.pressed:
		return stand_state

	return self

func animation_process() -> void:
	if (logic.direction_pressed.x == 0):
		set_variation(0) # ["idle"]
		play_animation()
	else :
		set_variation(1) # ["walk"]
		play_animation()

func enter(previous_state : State = null) -> State:
	var next_state = branch()
	if next_state != self:
		return next_state
	play_animation()
	logic.crouch.ing = true
	# change hitbox in player or here? maybe it should be called in physics frame
	print(self.name)
	return next_state

# func side_crouch_physics_process(delta, m : MovementData = movement):
# 	if logic.direction_pressed.x == 0.0:
# 		return
# 	if -m.side_instant_speed_return_thresh*speed_ratio < m.velocity.x*logic.direction_pressed.x \
# 		and m.velocity.x*logic.direction_pressed.x < m.side_instant_speed*speed_ratio :
# 		m.velocity.x = logic.direction_pressed.x*m.side_instant_speed*speed_ratio
# 	if (m.velocity.x*logic.direction_pressed.x >= m.side_speed_max*speed_ratio) :
# 		pass # in the same logic.direction_pressed.x as velocity and faster than max
# 	else :
# 		m.velocity.x += logic.direction_pressed.x*m.side_accel*accel_ratio*delta
# 		if (m.velocity.x*logic.direction_pressed.x > m.side_speed_max*speed_ratio) :
# 			m.velocity.x = logic.direction_pressed.x*m.side_speed_max*speed_ratio

## Called by the parent StateMachine during the _physics_process call, after
## the StatusLogic physics_process call.
func physics_process(delta) -> State:
	var next_state = branch()
	if next_state != self:
		return next_state

	var m : MovementData = movement.duplicate(false)
	m.set_ambient(ambient_modifier.apply(movement.ambient))
	# side_crouch_physics_process(delta)
	side_move_physics_process(delta, m)

	# update player position
	if player.physics_enabled:
		movement_physics_process(delta, m)

	# TODO : weird handling of velocity due to being inside movementdata:
	movement.velocity = m.velocity
	return self


## Called just before entering the next State. Should not contain await or time
## stopping functions
func exit():
	super()
	logic.crouch.ing = false
