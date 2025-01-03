extends State
class_name PlayerState

@export var player : Player
@export var logic : PlayerStatusLogic

@export var animation_player : AnimationPlayer
# @onready var animation_player : AnimationPlayer = player.animation_player ## player animation player
var animation_variations : Array = [] # Array[Array[String]]
## variation can be set by another State node, in order to perform an appropriate animation
@export var variation : int = 0 : set = set_variation #, get = get_animation_player
var variation_playing = -1

func set_variation(v : int):
	variation = v % max(animation_variations.size(),1)

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

## handle the animation modification depending on logic
## can call play_animation
func animation_process() -> void:
	pass

## Called by the parent StateMachine during the _process call, after
## the StatusLogic process call.
func process(delta) -> State:
	animation_process()
	return self

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
