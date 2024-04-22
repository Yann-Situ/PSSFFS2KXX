extends PlayerMovementState

@export var ambient_modifier : AmbientDataModifier ## ambient modifier for during slide
@export var duration : float = 1.2 ## max time of the slide in seconds
#need to handle hit/collision box resizing + crouch parameters + jump

@export var belong_state : State
@export var action_state : State
@export var fall_state : State
@export var crouch_state : State

var end_slide = false # set to true after timer and if not pressed down # TODO
@export var end_slide_finished = false # set to true at the end of animation ["end_slide"] # TODO
@onready var timer : Timer # time the duration between the beginning of the slide to the call to "end_slide"

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
	return self

func animation_process() -> void:
	if end_slide and variation == 0:
		set_variation(1)
		play_animation()

func enter(previous_state : State = null) -> State:
	end_slide = false
	end_slide_finished = false

	var next_state = branch()
	if next_state != self:
		return next_state
	play_animation()
	print(self.name)
	logic.slide.ing = true
	# timer = self.get_tree().create_timer(2.0)
	timer.start()
	# change hitbox
	return next_state

func end_timer():
	end_slide = true

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
	if timer:
		timer.stop()
	logic.slide.ing = false
