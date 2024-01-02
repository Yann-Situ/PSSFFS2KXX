extends StatusLogic

@export var entity : Node2D
@export var rect : Rect2 = Rect2(400.0, 300.0, 100.0, 50.0)

var out = Status.new("out")
var up : Trigger = Trigger.new("up") # appropriate declaration
var down : Trigger = Trigger.new("down") # appropriate declaration
var left : Trigger = Trigger.new("left") # appropriate declaration
var right : Trigger = Trigger.new("right") # appropriate declaration
var accept : Trigger = Trigger.new("accept") # appropriate declaration

func _ready():
	up = input_controller.up
	down = input_controller.down
	left = input_controller.left
	right = input_controller.right
	accept = input_controller.accept
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

## update the status using logic.
func update_status():
	out.ing = !rect.has_point(entity.position)
