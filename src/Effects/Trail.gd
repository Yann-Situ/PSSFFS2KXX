extends Line2D

var wildness := 15.0
var min_spawn_distance := 5.0
var gravity := Vector2.UP
var trail_fade_time := 1.0
var point_lifetime = 0.5
var tick_speed := 0.04

var tick := 0.0
var wild_speed := 0.1
var point_age := [0.0]
var stopped := false

onready var tween := $Decay

func _ready():
	set_as_toplevel(true)
	clear_points()

func stop():
	stopped = true
	tween.interpolate_property(self, "modulate:a", 1.0, 0.0, trail_fade_time, Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.start()


func _process(delta):
	if tick > tick_speed:
		tick = 0
		while point_age.front() > point_lifetime:
			point_age.pop_front()
			remove_point(0)
		for p in range(get_point_count()):
			point_age[p] += delta
			var rand_vector := Vector2( rand_range(-wild_speed, wild_speed), rand_range(-wild_speed, wild_speed) )
			points[p] += gravity + ( rand_vector * wildness * point_age[p] )
	else:
		tick += delta


func add_point(point_pos:Vector2, at_pos := -1):
	if get_point_count() > 0 and point_pos.distance_to( points[get_point_count()-1] ) < min_spawn_distance:
		return
	point_age.append(0.0)
	.add_point(point_pos, at_pos)


func _on_Decay_tween_all_completed():
	queue_free()
