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
@export var position : Vector2 = Vector2(200.0,200.0)#px.s

var accept : Trigger = Trigger.new("accept") # appropriate declaration
var tween

func branch() -> State:
	if accept.just_released:
		accept.just_released = false # need a workaround?
		return out_state
	return self

func enter(previous_state : State = null) -> State:
	print("enter "+name)
	set_color(color)
	return branch()

## Called just before entering the next State. Should not contain await or time
## stopping functions
func exit():
	if tween:
		tween.kill() # Abort the previous animation.
	set_color(Color.BLACK)
	print("exit "+name)


## Called by the parent StateMachine during the _process call, after
## the StatusLogic process call.
func process(delta) -> State:
	if tween:
		tween.kill() # Abort the previous animation.
	tween = create_tween()
	tween.tween_property(sprite, "position", position, 2)
	return branch()
