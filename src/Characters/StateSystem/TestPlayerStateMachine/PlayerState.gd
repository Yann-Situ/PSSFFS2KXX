extends State
class_name TestPlayerState

@export var player : FakePlayer
@export var logic : StatusLogic

# @export var animation_player : AnimationPlayer
@onready var animation_player : AnimationPlayer = player.animation_player ## player animation player
var animation_variations : Array = [] # Array[Array[String]]
## variation can be set by another State node, in order to perform an appropriate animation
@export var variation : int = 0 : set = set_variation #, get = get_animation_player
var variation_playing = -1

func set_variation(v : int):
	variation = v % animation_variations.size()

func play_animation(priority = false):
	if !animation_player or animation_variations.is_empty():
		# push_warning("no animation or animation_player is null")
		return
	if animation_player.is_playing() and \
		(variation == variation_playing or (priority and variation < variation_playing)):
		return

	variation_playing = variation
	animation_player.stop()
	var animation_names = animation_variations[variation]
	for animation in animation_names:
		if animation_player.has_animation(animation):
			animation_player.queue(animation)
		else:
			push_error("animation "+animation+" doesn't exists in "+animation_player.name)

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

func exit():
	variation = 0
	variation_playing = -1
