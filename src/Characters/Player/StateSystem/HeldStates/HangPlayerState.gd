extends PlayerMovementState

@export var belong_handler : BelongHandler

@export_group("States")
@export var action_state : State
@export var belong_state : State
@export var fall_state : State
@export var jump_state : State

var holder_at_enter : Node2D = null

func _ready():
	animation_variations = [["hang"], ["hang_catch"]]

func branch() -> State:
	if !belong_handler.is_belonging() or logic.down.pressed:
		return fall_state
	if logic.holder_change:
		return belong_state
	if logic.action.can:
		return action_state

	if !logic.jump_press_timer.is_stopped():
		return jump_state
	return self

# func animation_process() -> void:
# 	pass

func enter(previous_state : State = null) -> State:
	holder_at_enter = belong_handler.current_holder
	var next_state = branch()
	if next_state != self:
		return next_state
	play_animation()
	print(self.name)

	# effects
	player.effect_handler.dust_start()
	GlobalEffect.bus_highpass_fade("MusicMaster", 5.5, -1, 1760, true, Tween.TRANS_LINEAR)

	return next_state

## Called by the parent StateMachine during the _physics_process call, after
## the StatusLogic physics_process call.
func physics_process(delta) -> State:
	var next_state = branch()
	if next_state != self:
		return next_state

	# no side for hanging

	# update player position
	if player.physics_enabled:
		delta *= movement.ambient.time_scale
		# apply alterables
		apply_force_alterable(delta, movement)
		apply_accel_alterable(delta, movement)
		apply_speed_alterable(delta, movement)
		player.set_velocity(movement.velocity)

		belong_handler.physics_process_character(delta)

		movement.velocity = player.velocity-movement.speed_alterable.get_value()
	return self

## Called just before entering the next State. Should not contain await or time
## stopping functions
func exit():
	super()
	# if we exit the hang state but we are still on the same holder, get_out
	if belong_handler.belongs_to(holder_at_enter):
		belong_handler.get_out()
	# logic.belong_ing = belong_handler.is_belonging() # not necessary anymore as belong_in calls is_belonging in the getter
	holder_at_enter = null
	GlobalEffect.bus_highpass_fade_in("MusicMaster", 0.6)
