extends StateTestColor

# @export var stat_1 : Status # wrong declaration for the State system
# @export var stat_2 : Status = Status.new("stat_2") # appropriate declaration but the exported variable will be redifined by the StatusLogic
#
# var stat_3 : Status # wrong declaration for the State system
# var stat_4 : Status = Status.new("stat_4") # appropriate declaration
#
# @export var trig_1 : Trigger # wrong declaration for the State system
# @export var trig_2 : Trigger = Trigger.new("trig_2") # appropriate declaration but the exported variable will be redifined by the StatusLogic
#
# var trig_3 : Trigger # wrong declaration for the State system
# var trig_4 : Trigger = Trigger.new("trig_4") # appropriate declaration

@export var out_state : State
@export var speed : float = 100.0#px.s

var out : Status = Status.new("out") # appropriate declaration
var up : Trigger = Trigger.new("up") # appropriate declaration
var down : Trigger = Trigger.new("down") # appropriate declaration
var left : Trigger = Trigger.new("left") # appropriate declaration
var right : Trigger = Trigger.new("right") # appropriate declaration

func branch() -> State:
	if out.ing:
		return out_state
	return self

func enter(previous_state : State = null) -> State:
	print("enter "+name)
	set_color(color)
	return branch()

## Called just before entering the next State. Should not contain await or time
## stopping functions
func exit():
	set_color(Color.WHITE)
	print("exit "+name)

## Called by the parent StateMachine during the _process call, after
## the StatusLogic process call.
func process(delta) -> State:
	var v = Vector2.ZERO
	if up.pressed:
		v += Vector2.UP
	if down.pressed:
		v += Vector2.DOWN
	if left.pressed:
		v += Vector2.LEFT
	if right.pressed:
		v += Vector2.RIGHT
	sprite.position += speed*delta*v
	return branch()
