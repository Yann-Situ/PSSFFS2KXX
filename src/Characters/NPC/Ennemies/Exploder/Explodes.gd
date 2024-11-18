extends State

@export var entity : Node2D
@export var logic : StatusLogic
@export var animation_player : AnimationPlayer

@export var explosion_data : ExplosionData

## Called when entering this State.
## If there is an immediate transition, return the next State, otherwise return
## this state or null.
func enter(previous_state : State = null) -> State:
	animation_player.play("explodes")
	return self

## called by animation "explodes"
func explodes():
	GlobalEffect.make_distortion(entity.global_position, 1.5, "massive", Vector2(256,256))
	GlobalEffect.make_explosion(entity.global_position, explosion_data)
