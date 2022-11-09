extends Node

signal direction_changed(dir)

export (int) var initial_direction = 1 # 0 makes an idle pedestrian
export (float) var ai_timer_min = 1.0 #s
export (float) var ai_timer_max = 4.0 #s

export (float) var walk_speed_min = 50.0
export (float) var walk_speed_max = 80.0

export (float) var proba_idle = 0.2 #
export (float) var proba_change_direction = 0.4 #

var rng = RandomNumberGenerator.new()
var timer
var walk_speed
onready var direction = initial_direction
onready var last_direction = initial_direction

func _ready():
	rng.seed = hash(get_instance_id())
	timer = Timer.new()
	timer.set_one_shot(true)
	self.add_child(timer)
	timer.connect("timeout", self, "_on_Timer_timeout")
	timer.start(rng.randf_range(ai_timer_min, ai_timer_max))
	walk_speed = rng.randf_range(walk_speed_min, walk_speed_max)

func _on_Timer_timeout():
	var act = rng.randf_range(0.0,1.0)
	if direction == 0:
		if act < proba_change_direction:
			direction = -last_direction
			walk_speed = rng.randf_range(walk_speed_min, walk_speed_max)
			emit_signal("direction_changed", direction)
		else :
			direction = last_direction
			walk_speed = rng.randf_range(walk_speed_min, walk_speed_max)
			emit_signal("direction_changed", direction)
	else:
		if act < proba_idle:
			last_direction = direction
			direction = 0
			emit_signal("direction_changed", direction)
	timer.start(rng.randf_range(ai_timer_min, ai_timer_max))
