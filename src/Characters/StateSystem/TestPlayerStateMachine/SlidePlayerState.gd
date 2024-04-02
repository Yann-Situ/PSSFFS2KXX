extends TestPlayerMovementState

@export var movement_modifier : MovementDataModifier
@export var duration : float = 1.2 ## max time of the slide in seconds
#need to handle hit/collision box resizing + crouch parameters + jump

@export var belong_state : State
@export var action_state : State
@export var fall_state : State
@export var crouch_state : State

var end_slide = false # set to true after timer and if not pressed down # TODO
@export var end_slide_finished = false # set to true at the end of animation ["end_slide"] # TODO
@onready var timer : Timer

func _ready():
	animation_variations = [["begin_slide", "slide_loop"], ["end_slide"]]
	timer = Timer.new()
	timer.wait_time = duration
	timer.timeout.connect(end_timer)
	self.add_child(timer)

func branch() -> State:
	if logic.belong.ing:
		return belong_state
	if logic.action.can:
		return action_state
	if !logic.floor.ing:
		return fall_state

	if !logic.down.pressed:
		end_slide = true
		timer.stop()
	if end_slide and end_slide_finished:
		return crouch_state
	if end_slide:
		set_variation(1)
		play_animation()
	return self

func enter(previous_state : State = null) -> State:
	end_slide = false
	end_slide_finished = false 
	
	var next_state = branch()
	if next_state != self:
		return next_state
	
	set_variation(0)
	play_animation()
	print(self.name)
	
	logic.slide.ing = true
	# timer = self.get_tree().create_timer(2.0)
	timer.start()
	# change hitbox
	return next_state

func end_timer():
	end_slide = true

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

	# handle run and walls ?
	var m = movement_modifier.apply(movement)
	# side_crouch_physics_process(delta)
	side_move_physics_process(delta, m)

	# update player position
	if player.physics_enabled:
		movement_physics_process(delta, m)
	return self


## Called just before entering the next State. Should not contain await or time
## stopping functions
func exit():
	super()
	if timer:
		timer.stop()
	logic.slide.ing = false
