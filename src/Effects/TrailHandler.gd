extends Node2D

export var wildness := 15.0
export var min_spawn_distance := 5.0
export var gravity := Vector2.UP
export var gradient_col : Gradient = Gradient.new()
export var width := 20.0
export var width_curve : Curve = Curve.new()
export var trail_fade_time := 1.0
export var point_lifetime = 0.5
export var tick_age := 0.04
export var texture : Texture = load("res://assets/art/effects/trail.png")

var TrailScene = preload("res://src/Effects/Trail.tscn")
var node_to_trail
var trail = null
var last_tick = 0.0
var tick_delay_save = 0.0

func set_node_to_trail(node):
	node_to_trail = node
	
################################################################################

func start(duration, tick_delay):
	if trail != null:
		trail.stop()
	var trail_instance: Line2D = TrailScene.instance()
	trail_instance.name = "TrailInstance"
	trail_instance.wildness = wildness
	trail_instance.min_spawn_distance = min_spawn_distance
	trail_instance.gravity = gravity
	trail_instance.gradient = gradient_col
	trail_instance.width = width
	trail_instance.width_curve = width_curve
	trail_instance.trail_fade_time = trail_fade_time
	trail_instance.point_lifetime = point_lifetime
	trail_instance.tick_age = tick_age
	trail_instance.texture = texture
	
	# [BUG] https://github.com/godotengine/godot/issues/45416
	# z_as_relative doesn't work through code... so we do not do like this :
	# trail_instance.z_as_relative = true
	# trail_instance.z_index = -1
	
	#trail_instance.z_as_relative = false
	#trail_instance.z_index = node_to_trail.z_index-1 # but bug when the ball is picked_up
	
	node_to_trail.add_child(trail_instance)
	trail = trail_instance
	if duration > 0.0:
		$TrailTimer.start(duration)
	$TrailTickTimer.start(tick_delay)
	tick_delay_save = tick_delay
	last_tick = OS.get_ticks_msec()/1000.0
	
func stop():
	$TrailTimer.stop()
	_on_TrailTimer_timeout()

func _on_TrailTimer_timeout():
	if trail != null:
		trail.stop()
		yield(get_tree().create_timer(trail.trail_fade_time), "timeout")
	$TrailTickTimer.stop()
	trail = null
	
func _on_TrailTickTimer_timeout():
	var tick = OS.get_ticks_msec()/1000.0
	if tick_delay_save == 0.0:
		print("error: tick_delay_save == 0 in "+self.name)
		return
	var nb_pts = floor((tick - last_tick)/tick_delay_save)
	if nb_pts > 1:
		var p0 = Vector2.ZERO
		if trail.get_point_count() > 0:
			p0 = trail.points[trail.get_point_count()-1] # last point
		for i in range(nb_pts):
			trail.add_point(1.0/nb_pts * 
				((nb_pts-i-1)*p0 + (i+1)*node_to_trail.global_position))
	else :
		trail.add_point(node_to_trail.global_position)
	last_tick = tick
