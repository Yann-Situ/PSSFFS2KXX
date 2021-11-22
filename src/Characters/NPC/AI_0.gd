extends Node

onready var Character = get_parent()
onready var S = Character.get_node("State")

export (float) var ai_timer_min = 0.5 #s
export (float) var ai_timer_max = 4.0 #s
var rng = RandomNumberGenerator.new()

func _ready():
	rng.seed = hash(Character.name)

func _on_Action_timeout():
	var act = rng.randi_range(0,9)
	match act:
		0, 1, 2 :
			print(Character.name+" left")
			S.left_p = true
			S.right_p = false
		3, 4, 5 :
			print(Character.name+" right")
			S.right_p = true
			S.left_p = false
		6, 7, 8, 9 :
			print(Character.name+" idle")
			S.right_p = false
			S.left_p = false
	$Action.start(rng.randf_range(ai_timer_min, ai_timer_max))
