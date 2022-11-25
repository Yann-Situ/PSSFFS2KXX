extends Node

signal direction_changed(dir)

export (int) var initial_direction = 0 setget set_initial_direction # 0 makes an idle pedestrian
export (float) var ai_timer_min = 1.0 #s
export (float) var ai_timer_max = 4.0 #s
export (float) var proba_idle = 0.2 #
export (float) var proba_stay_idle = 0.4 #
export (float) var proba_change_direction = 0.4 #

var rng = RandomNumberGenerator.new()
var timer
onready var direction = initial_direction
onready var last_direction = initial_direction

func set_initial_direction(val : int):
	initial_direction = val
	change_direction(val)
	last_direction = val

func _ready():
	rng.seed = hash(get_instance_id())
	timer = Timer.new()
	timer.set_one_shot(true)
	self.add_child(timer)
	timer.connect("timeout", self, "_on_Timer_timeout")
	timer.start(rng.randf_range(ai_timer_min, ai_timer_max))

func _on_Timer_timeout():
	var act = rng.randf()
	if direction == 0: # kind of simple finite state machine
		if act < proba_stay_idle:
			pass
		else:
			act = rng.randf()
			if act < proba_change_direction:
				change_direction(-last_direction)
			else :
				change_direction(last_direction)
	else:
		if act < proba_idle:
			change_direction(0)
	timer.start(rng.randf_range(ai_timer_min, ai_timer_max))

func change_direction(new_direction : int):
	if direction != new_direction:
		last_direction = direction
		direction = new_direction
		emit_signal("direction_changed", direction)
