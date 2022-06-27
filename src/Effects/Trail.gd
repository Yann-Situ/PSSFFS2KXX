extends Line2D

export (float) var min_point_spawn_distance := 5.0#pix
export (float) var wildness_amplitude := 200.0#pix/s
export (float, 0.001, 1.0) var wildness_tick := 0.02#s

export (float) var trail_fade_time := 5.0#s
export (float) var point_lifetime := 0.7#s
export (float, 0.001, 1.0) var point_lifetime_tick := 0.04#s

export (float, 0.001, 1.0) var addpoint_tick := 0.04#s
export (float) var lifetime := 0.0#s (if <= 0.0s, then the trail stays until stop is called)
export (bool) var autostart = true setget set_autostart

var node_to_trail = null setget set_node_to_trail

var wildness_tick_current := 0.0
var point_lifetime_tick_current := 0.0
var addpoint_tick_current := 0.0
var point_age := [0.0]
onready var wildness_amplitude_per_tick = wildness_amplitude*wildness_tick#pix

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
	set_as_toplevel(true)

func start():
	if lifetime > 0.0:
		$Timer.start(lifetime)
	set_process(true)

func stop():
	stopped = true
	$Decay.interpolate_property(self, "modulate:a", 1.0, 0.0, trail_fade_time)
	$Decay.start()
	#get_tree().create_timer(trail_fade_time)
	#call_deferred("queue_free")

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
				var rand_vector := Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0))
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
	.add_point(point_position, at_position)
	Global.add_trail_point()
	return true

# Warning : if the trail node has been reparented during the decay tween, this
# function might never be called because Tween._exit_tree calls stop_all().
func _on_Decay_tween_all_completed():
	queue_free()

func _on_Timer_timeout():
	stop()
