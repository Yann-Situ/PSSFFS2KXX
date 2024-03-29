extends Line2D

@export var min_point_spawn_distance : float = 5.0#pix
@export var wildness_amplitude : float = 200.0#pix/s
@export_range(0.001,1.0) var wildness_tick : float = 0.02#s
@export_range(0.001,1.0) var point_lifetime_tick : float = 0.05#s
@export_range(0.001,1.0) var addpoint_tick : float = 0.04#s

@export var trail_fade_time : float = 5.0#s
@export var point_lifetime : float = 0.7#s
@export var lifetime : float = 0.0#s (if <= 0.0s, then the trail stays until stop is called)
@export var autostart : bool = true : set = set_autostart

var node_to_trail = null : set = set_node_to_trail

var wildness_tick_current := 0.0
var point_lifetime_tick_current := 0.0
var addpoint_tick_current := 0.0
var point_age := [0.0]
@onready var wildness_amplitude_per_tick = wildness_amplitude*wildness_tick#pix

var stopped := false

func set_autostart(b : bool) -> void:
	autostart = b
	$Timer.set_autostart(autostart)
	set_process(autostart)

func set_node_to_trail(node : Node2D):
	node_to_trail = node
	clear_points()
	_add_point(node_to_trail.global_position)
	self.z_index = node_to_trail.z_index - 1

func _ready():
	set_as_top_level(true)

func start():
	if lifetime > 0.0:
		$Timer.start(lifetime)
	set_process(true)

func stop():
	stopped = true
	var tween_decay = self.create_tween()
	tween_decay.tween_property(self, "modulate:a", 0.0, trail_fade_time).from(1.0)
	tween_decay.tween_callback(self._on_tween_decay_completed)
	#tween_decay.start()

func _process(delta):
	if point_lifetime_tick_current > point_lifetime_tick:
		for p in range(get_point_count()):
			point_age[p] += point_lifetime_tick_current
		point_lifetime_tick_current = 0.0
		while point_age.front() > point_lifetime:
			point_age.pop_front()
			remove_point(0)
			Global.remove_trail_point()
	else:
		point_lifetime_tick_current += delta

	if wildness_tick_current > wildness_tick:
		var n = floor(wildness_tick_current/wildness_tick)
		wildness_tick_current = fmod(wildness_tick_current, wildness_tick)
		for i in range(n):
			for p in range(get_point_count()):
				var rand_vector := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
				points[p] += (rand_vector * wildness_amplitude_per_tick)
	else:
		wildness_tick_current += delta

	if node_to_trail != null:
		if addpoint_tick_current > addpoint_tick:
			var n = floor(addpoint_tick_current/addpoint_tick)
			addpoint_tick_current = fmod(addpoint_tick_current, addpoint_tick)
			if n > 1:
				var p0 = node_to_trail.global_position
				if get_point_count() > 0:
					p0 = points[get_point_count()-1] # last point
				for i in range(n):
					_add_point(1.0/n * ((n-i-1)*p0 + (i+1)*node_to_trail.global_position))
			else :
				_add_point(node_to_trail.global_position)
		else:
			addpoint_tick_current += delta

# Try to add a point and return true iff the point was added
func _add_point(point_position:Vector2, at_position := -1) -> bool:
	if get_point_count() > 0 and point_position.distance_to(points[get_point_count()-1]) < min_point_spawn_distance:
		return false
	if !Global.can_add_trail_point():
		return false
	point_age.append(0.0)
	self.add_point(point_position, at_position)
	Global.add_trail_point()
	return true

# Warning : if the trail node has been reparented during the decay tween, this
# function might never be called because Tween._exit_tree calls stop_all().
func _on_tween_decay_completed():
	queue_free()

func _on_Timer_timeout():
	stop()
