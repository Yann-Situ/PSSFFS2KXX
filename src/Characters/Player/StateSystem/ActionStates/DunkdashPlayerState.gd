extends PlayerMovementState

@export var selectable_handler : SelectableHandler

@export var no_side_delay : float = 0.2#s
@export var no_friction_delay : float = 0.3#s
@export var dunkdash_speed : float = 800#pix/s
@export var dunkdash_speed_belong : float = 600## when the dunkdash end by entering belong_state (e.g grind or hang) (in pix/s)
@export var end_speed_ratio : float = 0.35 ## velocity will be multiplied by this amount at the end of the dunkdash
@export var ghost_modulate : Color# (Color, RGBA)
@export var sound_effect : AudioStreamPlayer2D

@export_group("States")
@export var belong_state : State
@export var dunk_state : State
@export var fall_state : State

var velocity_save = Vector2.ZERO
var accel_alterer = AltererMultiplicative.new(0.0)
var dash_velocity = Vector2.ZERO

var end_dash = false # set to true at the end of animation ["dunkdash"]

func _ready():
	animation_variations = [["dunkdash"], ["dunkdash_2"]] # [["animation_1", "animation_2"]]

func branch() -> State:
	if logic.belong_ing:
		return belong_state
	if logic.dunk.can and logic.accept.pressed:
		return dunk_state
	# handle the end of the dash
	# handle dunkdash in dunkdash TODO
	if end_dash:
		return fall_state
	return self

func enter(previous_state : State = null) -> State:
	end_dash = false

	var next_state = branch()
	if next_state != self:
		return next_state
	set_variation(randi_range(0,1))
	play_animation()

	logic.dunkdash.ing = true
	# logic.action.ing is already set in PlayerStatusLogic.gd
	logic.no_side_timer.start(no_side_delay)
	logic.no_friction_timer.start(no_friction_delay)

	player.add_accel(accel_alterer)

	var target_node : Node2D = null
	if selectable_handler.has_selectable_dunkdash():
		target_node = selectable_handler.get_selectable_dunkdash().parent_node
	else:
		printerr("dunkdash but selectable_handler.has_selectable_dunkdash() returned false")
		return fall_state # or stand_state?

	velocity_save = movement.velocity
	
	var target_velocity = target_node.get("linear_velocity")
	if target_velocity == null: # if no velocity
		target_velocity = Vector2.ZERO
		
	dash_velocity = GlobalMaths.anticipate_dash_velocity(player.global_position,
		target_node.global_position, movement.velocity, target_velocity, dunkdash_speed)
	movement.velocity = dash_velocity

	var dash_dir_x = sign(dash_velocity.x)
	player.set_flip_h(dash_dir_x <0)
	logic.direction_sprite = -1 if dash_dir_x <0 else 1
	logic.direction_sprite_change.can = false

	# effects
	if logic.ball_handler.has_ball():
		var ball = logic.ball_handler.held_ball
		ball.on_dunkdash_start(player)
		player.effect_handler.ghost_start(0.21,0.05, Color.WHITE,ball.get_dash_gradient())
	else:
		player.effect_handler.ghost_start(0.21,0.05, ghost_modulate)
	player.effect_handler.cloud_start()
	GlobalEffect.make_distortion(player.global_position, 0.75, "fast_soft")
	Global.camera.screen_shake(0.2,10)
	GlobalEffect.bus_lowpass_fade_out("MusicMaster", 0.05, 2520)
	GlobalEffect.bus_highpass_fade_out("MusicMaster", 0.05, 220)
	if sound_effect:
		sound_effect.play()

	print(self.name + " - velocity: " + str(dash_velocity.length()))
	return next_state


## Called by the parent StateMachine during the _physics_process call, after
## the StatusLogic physics_process call.
func physics_process(delta) -> State:
	var next_state = branch()
	if next_state != self:
		return next_state

	# side_move_physics_process(delta) # no side during dunkdash

	# update player position
	if player.physics_enabled:
		var save = movement.velocity.length()
		movement_physics_process(delta)
	return self

## should be called by animation
func dash_end():
	end_dash = true

## Called just before entering the next State. Should not contain await or time
## stopping functions
func exit():
	super()
	player.remove_accel(accel_alterer)
	logic.dunkdash.ing = false
	logic.direction_sprite_change.can = true
	GlobalEffect.bus_lowpass_fade_in("MusicMaster", 0.05)
	GlobalEffect.bus_highpass_fade_in("MusicMaster", 0.05)

	# if not logic.is_grinding and not logic.is_hanging : # TODO, translate this:
	
	
	var temp_vel_l = movement.velocity.length()
	var vel_dir = Vector2.ZERO
	if temp_vel_l != 0.0: #avoid zero division
		vel_dir = movement.velocity/temp_vel_l # vel_dir is not always equals to dash_dir (e.g if there is an obstacle on the dash path)
	var temp_vel_save_dot = velocity_save.dot(vel_dir)
	
	var new_speed = 0.0
	if logic.belong_ing:
		var dash_velocity_belong_dot = dunkdash_speed_belong*dash_velocity.normalized().dot(vel_dir)
		new_speed = max(dash_velocity_belong_dot, temp_vel_save_dot)
	else:
		new_speed = max(end_speed_ratio*temp_vel_l, temp_vel_save_dot)
		
	movement.velocity = new_speed * vel_dir

	if !logic.belong_ing and logic.direction_pressed.x * movement.velocity.x < 0:
		movement.velocity.x *= end_speed_ratio # again, so *end_speed_ratio^2 when also match the first case

#	if logic.has_ball: # WARNING the ball can change during the dash!
#		logic.active_ball.on_dunkdash_end(P)
