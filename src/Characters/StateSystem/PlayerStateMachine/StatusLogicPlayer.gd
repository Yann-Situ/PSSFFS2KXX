extends StatusLogic

@export var player : FakePlayer

var belong : Status = Status.new("belong") # appropriate declaration
var action : Status = Status.new("action") # appropriate declaration
var jump : Status = Status.new("jump") # appropriate declaration
var floor : Status = Status.new("floor") # appropriate declaration
var wall : Status = Status.new("wall") # appropriate declaration
var run : Status = Status.new("run") # appropriate declaration
var crouch : Status = Status.new("crouch") # appropriate declaration
var stand : Status = Status.new("stand") # appropriate declaration

var up : Trigger = Trigger.new("up") # appropriate declaration
var down : Trigger = Trigger.new("down") # appropriate declaration
var left : Trigger = Trigger.new("left") # appropriate declaration
var right : Trigger = Trigger.new("right") # appropriate declaration

var direction_pressed = Vector2.ZERO
var direction_sprite = 1

func _ready():
	up = input_controller.up
	down = input_controller.down
	left = input_controller.left
	right = input_controller.right

	stand.can = true
	run.can = true

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
	if player.flip_h:
		direction_sprite = -1
	else:
		direction_sprite = 1

	floor.ing = player.is_on_floor()
	jump.can = floor.ing # TODO, more complex
	# jump.ing controled by jump state
	run.ing = abs(player.movement.velocity.x) > 10.0

	# update stand
	crouch.can = floor.ing
	crouch.ing = crouch.ing or (!stand.can and floor.ing)
