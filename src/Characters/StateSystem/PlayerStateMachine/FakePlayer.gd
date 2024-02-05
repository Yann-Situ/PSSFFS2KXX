extends CharacterBody2D
class_name FakePlayer

@export var movement : MovementData
@export var physics_enabled : bool = true
var flip_h : bool = false : set = set_flip_h

func _ready():
	pass

func set_flip_h(b : bool):
	flip_h = b

func _process(delta):
	$LabelState.text = $StateMachine.current_state.name + "\n" + str($StateMachine.current_state.variation)
	$LabelVelocity.text = ("(%5.1f" % movement.velocity.x)+(", %5.1f" % movement.velocity.y)+")"
