extends PlayerMovementState

#need to handle hit/collision box resizing + crouch parameters + jump

# the following var is not working yet
@export var speed_threshold : float = 0.0 ## pix/s. The minimal vertical downward speed that triggers landing animation

@export_group("States")
@export var belong_state : State
@export var action_state : State
@export var fall_state : State
@export var jump_state : State
@export var stand_state : State
@export var crouch_state : State

var land_finished = false # set true at the end of the animation, set false at enter

func _ready():
	animation_variations = [["land"], ["land_roll"]]

func branch() -> State:
	if logic.belong_ing:
		return belong_state
	if logic.action.can:
		return action_state

	if logic.jump.can and !logic.jump_press_timer.is_stopped():
		#logic.floor.ing = false # TEMPORARY solution to avoid infinite recursion
		return jump_state
	if !logic.floor.ing:
		if !logic.ray_handler.is_above_floor():
			return fall_state
		else :
			print("--- land above floor")

	if land_finished:
		return crouch_state
	return self

func enter(previous_state : State = null) -> State:
	# print(movement.velocity.y) # TODO not working yet as the velocity at this time can be 0 or the previous vertical velocity...
	if movement.velocity.y < speed_threshold:
		return stand_state
	land_finished = false
	var next_state = branch()
	if next_state != self:
		return next_state
	play_animation()
	logic.crouch.ing = true
	# change hitbox
	print(self.name)

#	var timer = get_tree().create_timer(0.5) # TODO remove for animation handling
#	timer.timeout.connect(self.on_land_finished)
	
	# effects
	player.effect_handler.cloud_start()

	return next_state

func on_land_finished():
	print("--- land finished")
	land_finished = true

## Called just before entering the next State. Should not contain await or time
## stopping functions
func exit():
	# crouch set to false as the exit, but if next state is crouch, it will be reset to true at crouch.enter()
	super()
	logic.crouch.ing = false
