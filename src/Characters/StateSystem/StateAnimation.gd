extends State
class_name StateAnimation

@export var animation_names : Array[String] = [] #: set = set_animation_names, get = get_animation_names ##
@export var animation_player : AnimationPlayer #: set = set_animation_player, get = get_animation_player ##
## variation can be set by another State node, in order to perform an appropriate animation
@export var variation : int = 0 : set = set_variation #, get = get_animation_player

func set_variation(v : int):
	variation = variation % animation_names.size()

func play_animation():
	if !animation_player or animation_names.is_empty():
		return
	var animation_name = animation_names[variation]
	if animation_player.has_animation(animation_name):
		animation_player.play("animation_name")
	else:
		push_error("animation "+animation_name+" doesn't exists in "+animation_player.name)

func enter(previous_state : State = null) -> State:
	play_animation()
	return self
