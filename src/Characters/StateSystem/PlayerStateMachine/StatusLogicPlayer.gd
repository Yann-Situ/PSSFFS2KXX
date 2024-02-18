extends StatusLogic

@export var player : FakePlayer

var belong : Status = Status.new("belong") #
var action : Status = Status.new("action") #
var jump : Status = Status.new("jump") # is set by state, can set by timers
var floor : Status = Status.new("floor") # physical
var wall : Status = Status.new("wall") # physical
var run : Status = Status.new("run") #
var crouch : Status = Status.new("crouch") # partly physical, partly set by state
var stand : Status = Status.new("stand") # can set physicaly
var slide : Status = Status.new("slide") #

var up : Trigger = Trigger.new("up") #
var down : Trigger = Trigger.new("down") #
var left : Trigger = Trigger.new("left") #
var right : Trigger = Trigger.new("right") #

var direction_pressed = Vector2.ZERO
var direction_sprite = 1
var direction_sprite_changed = false

func _ready():
	up = input_controller.up
	down = input_controller.down
	left = input_controller.left
	right = input_controller.right

	stand.can = true
	run.can = true

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

## update the status using logic.
func update_status():

	# direction_sprite is 1 or -1 but direction_pressed.x can also be 0:
	direction_sprite_changed = (direction_sprite*direction_pressed.x < 0)
	if direction_sprite_changed:
		# we need to change sprite direction
		player.set_flip_h(direction_pressed.x < 0)
		direction_sprite *= -1

	floor.ing = player.is_on_floor()
	jump.can = floor.ing # TODO, more complex
	# jump.ing controled by jump state
	run.ing = abs(player.movement.velocity.x) > 10.0

	# update stand
	crouch.can = floor.ing
	crouch.ing = crouch.ing or (!stand.can and floor.ing)
