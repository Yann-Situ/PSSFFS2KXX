extends Node2D

export var wildness := 15.0
export var min_spawn_distance := 5.0
export var gravity := Vector2.UP
export var gradient_col : Gradient = Gradient.new()
export var width := 20.0
export var width_curve : Curve = Curve.new()
export var trail_fade_time := 1.0
export var point_lifetime = 0.5
export var tick_speed := 0.04
export var texture : Texture = load("res://assets/art/effects/trail.png")

var TrailScene = preload("res://src/Effects/Trail.tscn")
var node_to_trail
var trail = null

func set_node_to_trail(node):
	node_to_trail = node
	

################################################################################

func start(duration, tick_delay):
	if trail != null:
		trail.stop()
	var trail_instance: Line2D = TrailScene.instance()
	trail_instance.wildness = wildness
	trail_instance.min_spawn_distance = min_spawn_distance
	trail_instance.gravity = gravity
	trail_instance.gradient = gradient_col
	trail_instance.width = width
	trail_instance.width_curve = width_curve
	trail_instance.trail_fade_time = trail_fade_time
	trail_instance.point_lifetime = point_lifetime
	trail_instance.tick_speed = tick_speed
	trail_instance.texture = texture
	
	node_to_trail.add_child(trail_instance)
	trail = trail_instance
	if duration > 0.0:
		$TrailTimer.start(duration)
	$TrailTickTimer.start(tick_delay)
	
func stop():
	$TrailTimer.stop()
	_on_TrailTimer_timeout()

func _on_TrailTimer_timeout():
	$TrailTickTimer.stop()
	if trail != null:
		trail.stop()
		trail = null

func _on_TrailTickTimer_timeout():
	trail.add_point(node_to_trail.global_position)
