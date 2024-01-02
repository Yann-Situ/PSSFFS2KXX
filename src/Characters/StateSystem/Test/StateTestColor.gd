extends State
class_name StateTestColor

@export var sprite : Node2D #: set = set_sprite, get = get_sprite ##
@export var color : Color

func _ready():
	print(name+":")
	print(str(get_status_requirements())) # print ['stat_2', 'stat_4']
	print(str(get_trigger_requirements())) # print ['trig_2', 'trig_4']

func set_color(col : Color):
	if sprite:
		sprite.set_modulate(col)
	else:
		push_warning(name+": sprite is null")

func enter(previous_state : State = null) -> State:
	return self

## Called just before entering the next State. Should not contain await or time
## stopping functions
func exit():
	pass

## Called by the parent StateMachine during the _process call, after
## the StatusLogic process call.
func process(delta) -> State:
	return self
