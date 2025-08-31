extends PlayerMovementState

@export var selectable_handler : SelectableHandler
@export var belong_handler : BelongHandler

@export var sound_effect : AudioStreamPlayer2D

@export_group("States")
@export var belong_state : State
@export var fall_state : State

var basket_at_enter : Node2D = null
var position_tween : Tween
var end_dunk : bool = false # set to true at the end of animation ["dunk"]

func _ready():
	animation_variations = [["dunk"], ["dunk_2"]] # [["animation_1", "animation_2"]]

func branch() -> State:
	if logic.belong_ing:
		return belong_state
	# if logic.action.can:
	# 	return action_state
	# handle the end of the dunk
	if end_dunk:
		return fall_state
	return self

func enter(previous_state : State = null) -> State:
	end_dunk = false
	var next_state = branch()
	if next_state != self:
		return next_state
	play_animation()

	logic.dunk.ing = true
	logic.belong_can = false
	# logic.action.ing is already set in PlayerStatusLogic.gd

	if !selectable_handler.has_selectable_dunk():
		printerr("dunk but selectable_handler.has_selectable_dunk() returned false")
		return fall_state

	basket_at_enter = selectable_handler.get_selectable_dunk().parent_node
	if !basket_at_enter is NewBasket:
		basket_at_enter = null
		printerr("dunk but selectable_handler.has_selectable_dunk().parent_node is not NewBasket")
		return fall_state

	var dunk_position = basket_at_enter.get_dunk_position(player.global_position)
	var dunk_dir_x = basket_at_enter.global_position.x - player.global_position.x
	if dunk_dir_x != 0:
		player.set_flip_h(dunk_dir_x <0)
		logic.direction_sprite = -1 if dunk_dir_x < 0 else 1
	logic.direction_sprite_change.can = false

	if position_tween:
		position_tween.kill()
	position_tween = get_tree().create_tween()
	position_tween.set_parallel(false)
	position_tween.tween_property(player, "global_position",dunk_position,0.32)\
		.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	#position_tween.start()
	movement.velocity = Vector2.ZERO

	# TODO
	## WARNING the call to on_dunk has been moved to Basket.gd, it is now supposed
	## to be called at the moment of the dunk impact.
	# if S.active_ball != null:
	# 	S.active_ball.on_dunk(dunking_basket)
	GodotParadiseGeneralUtilities.frame_freeze(0.2, 0.2)
	GlobalEffect.bus_lowpass_fade_out("MusicMaster", 0.05, 5000)
	if sound_effect:
		sound_effect.play()
	#GlobalEffect.bus_fade("MusicMaster", 0.02, NAN, -12)
	#GlobalEffect.bus_lowpass_fade("MusicMaster", 0.3, 220, 10000, false)

	print(self.name)
	return next_state

## Called by the parent StateMachine during the _physics_process call, after
## the StatusLogic physics_process call.
func physics_process(delta) -> State:
	var next_state = branch()
	if next_state != self:
		return next_state

	# side_move_physics_process(delta) # no side during dunk

	# update player position
	# if player.physics_enabled:
	# 	movement_physics_process(delta) # no movement during dunk
	return self

## should be called by animation
func dunk_end():
	end_dunk = true
	
## should be called by animation
func dunk_impact():
	if basket_at_enter ==  null:
		printerr("impact but basket_at_enter is null")
		return
	basket_at_enter.dunk(player, logic.ball_handler.held_ball) # be careful here, not checking the ball_handler existence
	GlobalEffect.bus_lowpass_fade_in("MusicMaster", 0.03)
	#GlobalEffect.bus_fade_in("MusicMaster", 0.02)

## Called just before entering the next State. Should not contain await or time
## stopping functions
func exit():
	super()
	logic.dunk.ing = false
	logic.belong_can = true
	logic.direction_sprite_change.can = true
	if position_tween:
		position_tween.kill()
	#	if logic.has_ball: # WARNING the ball can change during the dunk!
	#		logic.active_ball.on_dunk_end(P)

	# handle hanging on the basket
	if !logic.down.pressed and basket_at_enter is NewBasket:
		belong_handler.get_in(basket_at_enter.character_holder)
