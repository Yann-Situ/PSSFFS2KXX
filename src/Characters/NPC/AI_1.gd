extends Node

onready var Character = get_parent()
onready var S = Character.get_node("State")

export (float) var ai_timer_min = 0.3 #s
export (float) var ai_timer_max = 2.0 #s
var rng = RandomNumberGenerator.new()

func _ready():
	rng.seed = hash(Character.name)

func _on_Action_timeout():
	var act
	var done = false
	if S.is_onwall :
		print(Character.name+" WALL")
		if S.last_wall_normal_direction == 1:
			act = 0.26
		else :
			act = 0.0
	else :
		act = rng.randf()
	
	while not done:
		if act < 0.25 :
			print(Character.name+" left")
			S.left_p = true
			S.right_p = false
			done = true
		elif act < 0.50:
			print(Character.name+" right")
			S.right_p = true
			S.left_p = false
			done = true
		elif act < 0.75:
			print(Character.name+" jump")
			S.jump_jp = true
			S.jump_p = true
			yield(get_tree().create_timer(rng.randf_range(0.0,0.8)), "timeout")
			S.jump_p = false
			S.jump_jr = true
			done = true
		elif act < 0.87:
			if S.can_dunkjump :
				print(Character.name+" dunkjump")
				S.dunk_jp = true
				S.dunk_p = true
				yield(get_tree().create_timer(rng.randf_range(1.0,2.5)), "timeout")
				S.dunk_p = false
				S.dunk_jr = true
			if S.can_dunk :
				print(Character.name+" dunk")
				S.dunk_jp = true
				S.dunk_p = true
				yield(get_tree().create_timer(0.1), "timeout")
				S.dunk_p = false
				S.dunk_jr = true
			if S.can_shoot :
				print(Character.name+" shoot")
				S.shoot_jr = true
				Character.BallHandler.set_shoot_vector( \
					rng.randf_range(100.0, 800.0) * \
					Vector2(rng.randfn(), rng.randfn()-1.0).normalized() \
					)
			done = true
		else :
			print(Character.name+" idle")
			S.right_p = false
			S.left_p = false
			done = true
	$Action.start(rng.randf_range(ai_timer_min, ai_timer_max))
