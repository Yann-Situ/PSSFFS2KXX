extends CharacterBody2D
class_name FakePlayer

@export var movement : TestMovementData
@export var physics_enabled : bool = true
@export var animation_player : AnimationPlayer
var flip_h : bool = false : set = set_flip_h


func _ready():
	pass

func set_flip_h(b : bool):
	flip_h = b
	if b:
		$Flipper.scale.x = -1.0
	else:
		$Flipper.scale.x = 1.0

func _process(delta):
	$LabelState.text = $StateMachine.current_state.name + "\n" + str($StateMachine.current_state.variation)
	$LabelVelocity.text = ("(%5.1f" % movement.velocity.x)+(", %5.1f" % movement.velocity.y)+")"
