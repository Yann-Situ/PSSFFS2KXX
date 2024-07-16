extends PlayerMovementState

@export var belong_handler : BelongHandler
@export var selectable_handler : SelectableHandler ## This is useful for the grindash, which is handled in this state node

@export var no_side_delay : float = 0.2#s
@export var grindash_speed : float = 600#pix/s

@export_group("States")
@export var action_state : State
@export var belong_state : State
@export var fall_state : State
@export var jump_state : State
#@export var grindash_state : State

var holder_at_enter : Node2D = null
var do_grindash = false

func _ready():
	animation_variations = [
		["grind-45"], ["grind-30"], ["grind-15"],
		["grind0"],
		["grind+15"], ["grind+30"], ["grind+45"],
		["dunkdash"], ["grind_freestyle"]]

func branch() -> State:
	if !belong_handler.is_belonging() or logic.down.pressed:
		return fall_state
	if logic.holder_change:
		return belong_state
	if logic.action.can:
		if logic.dunkdash.can and logic.accept.just_pressed:
			grindash()
		else:
			return action_state

	if !logic.jump_press_timer.is_stopped():
		return jump_state # maybe do some tricks
	return self

func animation_process() -> void:
	if do_grindash:
		set_variation(7) # grindash
		do_grindash = false
		play_animation(true)

	logic.direction_sprite_change.can = true
	var movement_dir_x = movement.velocity.x > 0
	player.set_flip_h(not movement_dir_x)
	logic.direction_sprite = 1 if movement_dir_x else -1
	logic.direction_sprite_change.can = false

	if !animation_player.is_playing() or variation_playing != 7:
		# do complicated stuff here:
		var dir = player.velocity
		if dir.x < 0:
			dir.x = -dir.x
		var grind_variation = 3+round(-dir.angle() * (12.0/PI))
		grind_variation = clamp(grind_variation,0,6)
		set_variation(grind_variation)
		play_animation()

func enter(previous_state : State = null) -> State:
	do_grindash = false
	holder_at_enter = belong_handler.current_holder
	var next_state = branch()
	if next_state != self:
		return next_state
	play_animation()

	var movement_dir_x = movement.velocity.x > 0
	player.set_flip_h(not movement_dir_x)
	logic.direction_sprite = 1 if movement_dir_x else -1
	logic.direction_sprite_change.can = false
	print(self.name)

	return next_state

## Called by the parent StateMachine during the _physics_process call, after
## the StatusLogic physics_process call.
func physics_process(delta) -> State:
	var next_state = branch()
	if next_state != self:
		return next_state

	# no side for grinding

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
	# if we exit the grind state but we are still on the same holder, get_out
	logic.direction_sprite_change.can = true
	if belong_handler.belongs_to(holder_at_enter):
		belong_handler.get_out()
	# logic.belong_ing = belong_handler.is_belonging() # not necessary anymore as belong_in calls is_belonging in the getter
	holder_at_enter = null

func grindash():
	var target : Node2D = null
	if selectable_handler.has_selectable_dunkdash():
		target = selectable_handler.get_selectable_dunkdash().parent_node
	else:
		printerr("grindash but selectable_handler.has_selectable_dunkdash() returned false")
		return # do nothing

	var target_velocity = target.get("linear_velocity")
	if target_velocity == null: # if no velocity
		target_velocity = Vector2.ZERO

	var dash_velocity = GlobalMaths.anticipate_dash_velocity(player.global_position,
		target.global_position, movement.velocity, target_velocity, grindash_speed)
	movement.velocity = dash_velocity
	do_grindash = true
