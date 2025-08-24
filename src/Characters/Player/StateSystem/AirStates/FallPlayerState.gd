extends PlayerMovementState

@export var roll_speed_thresh : float = 50.0
@export var fall_run_speed_thresh : float = 350.0

@export_group("States")
@export var belong_state : State
@export var action_state : State
@export var land_state : State
@export var fallwall_state : State
@export var jump_state : State

# var belong : Status = Status.new(["belong"]) # appropriate declaration
# var action : Status = Status.new(["belong"]) # appropriate declaration
# var floor : Status = Status.new(["belong"]) # appropriate declaration
# var wall : Status = Status.new(["belong"]) # appropriate declaration

func _ready():
	animation_variations = [["fall","fall_loop"],["fall_run","fall_loop"],["fall_swag1","fall_loop"],["fall_swag2","fall_loop"]]

func branch() -> State:
	if logic.belong_ing:
		return belong_state
	if logic.action.can:
		return action_state

	if logic.jump.can and !logic.jump_press_timer.is_stopped():
		return jump_state # eventually coyote time, or double jump ?
	if (logic.floor.ing or logic.ray_handler.is_above_floor()) and movement.velocity.y >= 0.0: # floor.ing and locally falling
		if abs(movement.velocity.x) > roll_speed_thresh:
			land_state.set_variation(1)
		else:
			land_state.set_variation(0)
		return land_state
	if logic.wall.ing:
		return fallwall_state
	return self

# func animation_process() -> void:
# 	pass

func enter(previous_state : State = null) -> State:
	var next_state = branch()
	if next_state != self:
		return next_state
	print(self.name)
	# choose animation depending on shoot direction and state
	
	var r = randf()
	if r > 0.92:
		set_variation(2)
	elif r < 0.08:
		set_variation(3)
	elif abs(movement.velocity.x) > fall_run_speed_thresh :
		set_variation(1)
	else: 
		set_variation(0)
	play_animation()
	return next_state
