extends StatusLogic
class_name PlayerStatusLogic

@export var player : NewPlayer

@export var ball_handler : BallHandler
@export var shoot_handler : ShootHandler
@export var basket_handler : BasketHandler
@export var ray_handler : RayHandler
@export var held_handler : HeldHandler

var belong : Status = Status.new("belong") #
var action : Status = Status.new("action") #

var floor : Status = Status.new("floor") # ray_handler
var wall : Status = Status.new("wall") # ray_handler
var stand : Status = Status.new("stand") # ray_handler for can_stand
var side : Status = Status.new("side") #

var jump : Status = Status.new("jump") # ing set by state, can set by timers
var walljump : Status = Status.new("walljump") # ing set by state, can set by timers
var crouch : Status = Status.new("crouch") # partly physical, partly set by state
var slide : Status = Status.new("slide") #

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

var has_ball : bool = false # ball_handler

var up : Trigger = Trigger.new("up") #
var down : Trigger = Trigger.new("down") #
var left : Trigger = Trigger.new("left") #
var right : Trigger = Trigger.new("right") #

var direction_pressed = Vector2.ZERO
var direction_sprite = 1
var direction_sprite_changed = false

#Some action are for the moment not handled by states as they are somehow independent.
#Maybe there will be a parallel StateMachine for balls in the future. Those actions are:
#	- Released
#	- Interact
#	- Aim
#	- SelectBall
#	- Power
#	- Pickball

func _ready():
	up = input_controller.up
	down = input_controller.down
	left = input_controller.left
	right = input_controller.right

	stand.can = true
	side.can = true

	if player.flip_h:
		direction_sprite = -1
	else:
		direction_sprite = 1

	super._ready()

## Called by the parent StateMachine during the _physics_process call, before
## the State nodes physics_process calls.
func process(delta):
	update_triggers()
	update_status()
	# TODO add power, release, interact here? (targethandler?)
	# collision, life, camera and shooter are handled by player (targethandler?)
	# the choice is a bit arbitrary, I would handle non-state stuff in player._process

## update the triggers from the input_controller Node.
func update_triggers():
	input_controller.update_triggers()
	# up = input_controller.up
	# down = input_controller.down
	# left = input_controller.left
	# right = input_controller.right
	# accept = input_controller.accept
	# not necessary

	direction_pressed = Vector2.ZERO
	if up.pressed:
		direction_pressed += Vector2.UP
	if down.pressed:
		direction_pressed += Vector2.DOWN
	if left.pressed:
		direction_pressed += Vector2.LEFT
	if right.pressed:
		direction_pressed += Vector2.RIGHT

	if up.just_pressed:
		$JumpPressTimer.start()
	if accept.just_pressed:
		$DunkJumpPressTimer.start()

## update the status using logic.
func update_status():

	# action.ing
	action.ing = dunk.ing or dunkjump.ing or dunkdash.ing or shoot.ing

	# held_handler
	belong.can = held_handler.can_be_held
	belong.ing = held_handler.has_holder()

	# ball_handler
	pickball.can = ball_handler.can_pick
	release.can = ball_handler.has_ball()
	power.can = ball_handler.has_selected_ball()

	# ray_handler
	floor.ing = ray_handler.is_on_floor()
	wall.ing = ray_handler.is_on_wall()
	stand.can = ray_handler.can_stand()

	side.ing = abs(player.movement.velocity.x) > 30.0
	crouch.can = floor.ing
	crouch.ing = crouch.ing or (!stand.can and floor.ing)

	# basket_handler
	dunk.can = basket_handler.can_dunk() and not floor.ing and\
	 	$NoDunkTimer.is_stopped() and\
		(not action.ing or dunkjump.ing or dunkdash.ing)
	dunkdash.can = basket_handler.can_dunkdash()
	dunkjump.can = basket_handler.can_dunkjump()

	# shoot_handler
	shoot.can = shoot_handler.can_shoot_to_target() and\
		$NoShootTimer.is_stopped() and\
		(not action.ing)

	# timer dependent
	jump.can = not $JumpFloorTimer.is_stopped() and $NoJumpTimer.is_stopped()
	walljump.can = not $JumpWallTimer.is_stopped() and $NoJumpTimer.is_stopped()
	side.can = $NoSideTimer.is_stopped()

	# action.can
	action.can = dunk.can or dunkjump.can or dunkdash.can or shoot.can

	# direction_sprite is 1 or -1 but direction_pressed.x can also be 0:
	direction_sprite_changed = (direction_sprite*direction_pressed.x < 0)
	if direction_sprite_changed:
		# we need to change sprite direction
		player.set_flip_h(direction_pressed.x < 0)
		direction_sprite *= -1