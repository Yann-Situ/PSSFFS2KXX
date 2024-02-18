extends State
class_name PlayerState

@export var player : FakePlayer
@export var logic : StatusLogic

# @export var animation_player : AnimationPlayer
@onready var animation_player : AnimationPlayer = player.animation_player ## player animation player
var animation_names : Array[String] = []
## variation can be set by another State node, in order to perform an appropriate animation
@export var variation : int = 0 : set = set_variation #, get = get_animation_player

func set_variation(v : int):
	variation = v % animation_names.size()

func play_animation():
	if !animation_player or animation_names.is_empty():
		# push_warning("no animation or animation_player is null")
		return
	var animation_name = animation_names[variation]
	if animation_player.has_animation(animation_name):
		if animation_player.current_animation != animation_name:
			animation_player.play(animation_name)
	else:
		push_error("animation "+animation_name+" doesn't exists in "+animation_player.name)

func branch() -> State:
	# do some logic
	return self

func enter(previous_state : State = null) -> State:
	var next_state = branch()
	if next_state != self:
		return next_state
	play_animation()
	print(self.name)
	return next_state
