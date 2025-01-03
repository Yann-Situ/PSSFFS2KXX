extends StatusLogic
class_name PlayerStatusLogic

@export var player : Player

@export var ball_handler : BallHandler
@export var shoot_handler : ShootHandler
@export var selectable_handler : SelectableHandler
@export var ray_handler : RayHandler
@export var belong_handler : BelongHandler

# var belong : Status = Status.new("belong") #
var belong_ing : bool = false : get = get_belong_ing
var belong_can : bool = false : set = set_belong_can, get = get_belong_can
func get_belong_ing():
	belong_ing = belong_handler.is_belonging()
	return belong_ing
func get_belong_can():
	return belong_handler.can_belong and belong_can
func set_belong_can(b):
	belong_can = b
	belong_handler.can_belong = b

var action : Status = Status.new("action") #

var floor : Status = Status.new("floor") # ray_handler
var wall : Status = Status.new("wall") # ray_handler + direction pressed
var stand : Status = Status.new("stand") # ray_handler for can_stand
var side : Status = Status.new("side") #

var jump : Status = Status.new("jump") # ing set by state, can set by timers # ing is true when jumping or walljumping
var walljump : Status = Status.new("walljump") # ing set by state, can set by timers
var crouch : Status = Status.new("crouch") # partly physical, partly set by state
var slide : Status = Status.new("slide") #
var friction : Status = Status.new("friction") # set from timer, whether or not the player should undergo friction

var dunk : Status = Status.new("dunk") #
var dunkdash : Status = Status.new("dunkdash") #
var dunkjump : Status = Status.new("dunkjump") #
var shoot : Status = Status.new("shoot") #

var interact : Status = Status.new("interact") #
var aim : Status = Status.new("aim") #
var selectball : Status = Status.new("selectball") #
var release : Status = Status.new("release") #
var pickball : Status = Status.new("pickball") #
var power : Status = Status.new("power") #

var trigger_enabled : bool = true
var up : Trigger = Trigger.new("up") #
var down : Trigger = Trigger.new("down") #
var left : Trigger = Trigger.new("left") #
var right : Trigger = Trigger.new("right") #
var accept : Trigger = Trigger.new("accept") #
var key_power : Trigger = Trigger.new("power") #
var key_release : Trigger = Trigger.new("release") #
var key_interact : Trigger = Trigger.new("interact") #

var direction_pressed : Vector2 = Vector2.ZERO
var direction_sprite = 1
var direction_wall = 0 #last wall direction, 1 for wall at the right of player, -1 at the left
var direction_sprite_change = Status.new("direction_sprite_change")
var holder_change = false # if the holder just changed # reset to false by belong_state # TODO
# ing is when the direction changed in this frame
# can is if the direction can change in this frame

##timers
@onready var jump_press_timer : Timer = $JumpPressTimer
@onready var dunkjump_press_timer : Timer = $DunkJumpPressTimer
@onready var no_shoot_timer : Timer = $NoShootTimer
@onready var no_dunk_timer : Timer = $NoDunkTimer
@onready var no_jump_timer : Timer = $NoJumpTimer
@onready var no_side_timer : Timer = $NoSideTimer
@onready var no_friction_timer : Timer = $NoFrictionTimer
@onready var floor_timer : Timer = $JumpFloorTimer
@onready var wall_timer : Timer = $JumpWallTimer


# ## linked to a Timer, is set to true during a small time after pressing the button
# var jump_press_timing : bool = false
# var dunkjump_press_timing : bool = false
#
# ## linked to a Timer, is set to true if shoot is disable for a while
# var no_shoot : bool = false
# var no_dunk : bool = false
# var no_jump : bool = false
# var no_side : bool = false
#
# ## linked to a Timer, is set to true for a while after being on a wall or on floor (for coyote)
# var floor_timing : bool = false
# var wall_timing : bool = false

#Some action are for the moment not handled by states as they are somehow independent.
#Maybe there will be a parallel StateMachine for balls in the future. Those actions are:
#	- Released
#	- Interact
#	- Aim
#	- SelectBall
#	- Power
#	- Pickball

################################################################################
func _ready():
	up = input_controller.up
	down = input_controller.down
	left = input_controller.left
	right = input_controller.right
	accept = input_controller.accept
	key_power = input_controller.power
	key_release = input_controller.release
	key_interact = input_controller.interact

	stand.can = true
	side.can = true
	direction_sprite_change.can = true

	if player.flip_h:
		direction_sprite = -1
	else:
		direction_sprite = 1

	super._ready()

func disable_input():
	print_debug("disable_input")
	trigger_enabled = false
	input_controller.force_release_triggers()
	update_triggers()
func enable_input():
	print_debug("enable_input")
	trigger_enabled = true
	

## Called by the parent StateMachine during the _physics_process call, before
## the State nodes physics_process calls.
func physics_process(delta):
	if trigger_enabled:
		update_triggers()
	update_status()
	# TODO add interact here? (targethandler?)
	# collision(?), life, camera and shooter are handled by player (targethandler?)
	# the choice is a bit arbitrary, I would handle non-state stuff in player._process

################################################################################

## update the triggers from the input_controller Node.
func update_triggers():
	input_controller.update_triggers()

	direction_pressed = Vector2.ZERO
	if up.pressed:
		direction_pressed += Vector2.UP
	if down.pressed:
		direction_pressed += Vector2.DOWN
	if left.pressed:
		direction_pressed += Vector2.LEFT
	if right.pressed:
		direction_pressed += Vector2.RIGHT
	player.movement.direction_pressed = direction_pressed

	if up.just_pressed:
		jump_press_timer.start()
	if accept.just_pressed:
		dunkjump_press_timer.start()

## update the status using logic.
func update_status():
	# action.ing
	action.ing = dunk.ing or dunkjump.ing or dunkdash.ing or shoot.ing

	# held_handler  # not necessary anymore as is_belonging is called in the getter etc.
	# belong_can = belong_handler.can_belong
	# belong_ing = belong_handler.is_belonging()

	# ball_handler
	pickball.can = !ball_handler.has_ball()
	ball_handler.can_pick = pickball.can
	release.can = ball_handler.has_ball()
	power.can = ball_handler.has_selected_ball()

	# ray_handler
	ray_handler.update_space_state()
	floor.ing = ray_handler.is_on_floor()
	if floor.ing:
		$JumpFloorTimer.start()
	wall.ing = ray_handler.is_on_wall() and direction_sprite == sign(direction_pressed.x)
	if wall.ing:
		direction_wall = direction_sprite
		$JumpWallTimer.start()
	stand.can = ray_handler.can_stand()

	side.ing = abs(player.movement.velocity.x) > 30.0
	crouch.can = floor.ing # I though of adding `or ray_handler.is_above_floor()` but I think this is a bad idea...
	crouch.ing = crouch.ing or (!stand.can and floor.ing)

	# selectable_handler
	dunk.can = selectable_handler.has_selectable_dunk() and not floor.ing and\
	 	no_dunk_timer.is_stopped() and\
		(not action.ing or dunkjump.ing or dunkdash.ing)
	dunkdash.can = selectable_handler.has_selectable_dunkdash() # and TODO remaining_dash > 0
	dunkjump.can = selectable_handler.has_selectable_dunkjump() and floor.ing

	# shoot_handler
	shoot.can = ball_handler.has_ball() and\
		selectable_handler.has_selectable_shoot() and\
		(not action.ing)

	# interaction_handler
	interact.can = not action.ing # for the moment, interact is handled in Player.gd (handle_interaction()), but maybe it will be suitable to incorporate it in a state_machine?

	# timer dependent
	jump.can = not floor_timer.is_stopped() and no_jump_timer.is_stopped()
	walljump.can = not wall_timer.is_stopped() and no_jump_timer.is_stopped()
	side.can = no_side_timer.is_stopped()
	friction.can = no_friction_timer.is_stopped()

	# action.can
	action.can = (dunkdash.can and accept.just_pressed) or \
		(dunk.can and accept.pressed) or \
		(dunkjump.can and accept.just_pressed and down.pressed) or \
		(shoot.can and key_release.just_pressed and not down.pressed)

	# direction_sprite is 1 or -1 but direction_pressed.x can also be 0:
	direction_sprite_change.ing = (direction_sprite*direction_pressed.x < 0) and\
	 	direction_sprite_change.can
	if direction_sprite_change.ing:
		# we need to change sprite direction
		player.set_flip_h(direction_pressed.x < 0)
		direction_sprite *= -1

################################################################################

func _on_belong_handler_holder_changed(new_holder):
	holder_change = true
