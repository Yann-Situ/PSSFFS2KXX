extends Node

signal direction_changed(dir)

@export var initial_direction : int = 0 :
	set = set_initial_direction # 0 makes an idle pedestrian
@export var ai_timer_min : float = 1.0 #s
@export var ai_timer_max : float = 4.0 #s
@export var proba_idle : float = 0.2 #
@export var proba_stay_idle : float = 0.4 #
@export var proba_change_direction : float = 0.4 #

var rng = RandomNumberGenerator.new()
var timer
@onready var direction = initial_direction
@onready var last_direction = initial_direction

func set_initial_direction(val : int):
	initial_direction = val
	change_direction(val)
	last_direction = val

func _ready():
	rng.seed = hash(get_instance_id())
	timer = Timer.new()
	timer.set_one_shot(true)
	self.add_child(timer)
	timer.timeout.connect(self._on_Timer_timeout)
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
		direction_changed.emit(direction)
