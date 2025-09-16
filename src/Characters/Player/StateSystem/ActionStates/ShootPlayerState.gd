extends PlayerMovementState

@export var selectable_handler : SelectableHandler

@export_group("States")
@export var belong_state : State
@export var dunk_state : State
@export var dunkdash_state : State
@export var dunkjump_state : State
@export var fall_state : State
@export var land_state : State
@export var jump_state : State

var end_shoot = false # set to true at the end of animation ["shoot"]
var enter_on_floor = true

func _ready():
	animation_variations = [["shoot_floor_fwd"], ["shoot_floor_bwd"], ["shoot_floor_down"], 
							["shoot_air_fwd"]  , ["shoot_air_bwd"]  , ["shoot_air_down"]]

func branch() -> State:
	if logic.belong_ing:
		return belong_state
	
	if logic.dunk.can and logic.accept.pressed:
		return dunk_state
	if logic.dunkjump.can and logic.accept.just_pressed and logic.down.pressed:
		return dunkjump_state
	if logic.dunkdash.can and logic.accept.just_pressed:
		return dunkdash_state
	
	# handle the end of the shoot
	# handle shoot in shoot TODO
	if !enter_on_floor and logic.floor.ing: # floor.ing and locally falling
		return land_state
	if enter_on_floor and logic.jump.can and !logic.jump_press_timer.is_stopped():
		return jump_state
	if end_shoot:
		return fall_state
	return self

func enter(previous_state : State = null) -> State:
	end_shoot = false
	var next_state : State = self
	## short version of branch():
	if not logic.ball_handler.has_ball():
		next_state = fall_state
	if logic.belong_ing:
		next_state = belong_state
	if logic.dunk.can and logic.accept.pressed:
		next_state = dunk_state
	if logic.dunkjump.can and logic.accept.just_pressed and logic.down.pressed:
		next_state = dunkjump_state
	if logic.dunkdash.can and logic.accept.just_pressed:
		next_state = dunkdash_state
	if next_state != self:
		return next_state
		
	enter_on_floor = logic.floor.ing
	logic.shoot.ing = true
	logic.direction_sprite_change.can = false
	# logic.action.ing is already set in PlayerStatusLogic.gd
	
	# Get Selectable
	var selectable : Selectable = null
	if selectable_handler.has_selectable_shoot():
		selectable = selectable_handler.get_selectable_shoot()
	else:
		printerr("shoot but selectable_handler.has_selectable_shoot() returned false")
		return fall_state # or stand_state?
	
	# Compute and handle shoot
	var ball : Ball = logic.ball_handler.held_ball
	var throw_position : Vector2 = logic.ball_handler.get_throw_position()
	var q = selectable.global_position - throw_position
	q.x*=1.1
	q.y*=1.1#px
	var bell_ratio = selectable.shoot_bell_ratio
	var angle = q.angle()
	if angle > PI/6.0 and angle < 5.0*PI/6.0:
		bell_ratio = min(bell_ratio, 0.8)
	var shoot_velocity = GlobalMaths.shoot_velocity_bell_ratio(q, bell_ratio, 625) # TODO change 625
	
	logic.ball_handler.throw_ball(throw_position, shoot_velocity)

	# choose animation depending on shoot direction and state
	if logic.floor.ing:
		var angle_shoot = shoot_velocity.angle()
		if angle_shoot > PI/8.0 and angle_shoot < 7.0*PI/6.0:
			set_variation(2)
		elif shoot_velocity.x * logic.direction_sprite < 0:
			set_variation(1)
		else: 
			set_variation(0)
	else :
		var angle_shoot = shoot_velocity.angle()
		if angle_shoot > PI/8.0 and angle_shoot < 7.0*PI/8.0:
			set_variation(5)
		elif shoot_velocity.x * logic.direction_sprite < 0:
			set_variation(4)
		else: 
			set_variation(3)
	play_animation()


	var element = ComboElement.new()
	element.name = "Shoot"
	element.additional_score = 100
	element.additional_multiplier = 0.0
	element.remaining_time = 1.0
	player.combo_handler.add_combo_element(element)
	print(self.name + " - velocity: " + str(shoot_velocity))
	return next_state


## Called by the parent StateMachine during the _physics_process call, after
## the StatusLogic physics_process call.
func physics_process(delta) -> State:
	var next_state = branch()
	if next_state != self:
		return next_state

	side_move_physics_process(delta)
	# update player position
	if player.physics_enabled:
		movement_physics_process(delta)
	return self

## should be called by animation
func shoot_end():
	end_shoot = true

## Called just before entering the next State. Should not contain await or time
## stopping functions
func exit():
	super()
	logic.shoot.ing = false
	logic.direction_sprite_change.can = true
