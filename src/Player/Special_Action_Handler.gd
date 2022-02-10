extends Node2D

onready var P = get_parent().get_parent()
onready var S = P.get_node("State")
onready var Selector = get_parent().get_node("Selector")

export var distaction = Vector2(8.1,0)
export var color = Color(1.0,0.3,0.1)
export (bool) var flip_h = false
var rays = []
var rays_flip = []
var rays_not_flip = []
var rays_res = []
var space_state

# Called when the node enters the scene tree for the first time.
func _ready():
	rays_not_flip = [$Ray_fwd_down, $Ray_fwd_up, $Ray_up_fwd, $Ray_up_bwd, \
		$Ray_down_fwd, $Ray_down_bwd, $Ray_slope_fwd, $Ray_slope_bwd]
	rays_flip = [$Ray_fwd_down_f, $Ray_fwd_up_f, $Ray_up_bwd, $Ray_up_fwd, \
		$Ray_down_bwd, $Ray_down_fwd, $Ray_slope_bwd, $Ray_slope_fwd]
	self.set_flip_h(P.flip_h)

func update_space_state():
	space_state = get_world_2d().direct_space_state
	for r in rays:
		r.updated = false

func cast(r): #we must have updated the space_state before
	if not r.updated:
		r.result = space_state.intersect_ray(P.position+r.position, \
			P.position+r.position+r.cast_to, \
			[P], P.collision_mask, true, false)
		r.updated = true

func update_basket():
	var selectable_node = null

	var selectables = $dunkjump_area.get_overlapping_areas()
	if !selectables.empty():
		# choose by priority selectables that are in direction_p, closest above player
		var b = selectables[0].get_parent() # `get_parent` because we're
		# detecting the basket_area node
		var q = (b.position-P.position)
		var direction = S.direction_p
		if direction == 0:
			if P.flip_h:
				direction = -1
			else :
				direction = 1
		var dir : int# not 0 in order to make direction*d=1 if q.x=0
		var Delta : float
		var best_y = 0.0
		var best_dist2 = $dunkjump_area/CollisionShape2D.shape.radius
		best_dist2 *= 2 * best_dist2
		var best_direction = -2

		for i in range(selectables.size()):
			b = selectables[i]
			if !b.is_jump_selectable:
				continue
			q = (b.global_position-P.global_position)
			# be carefull division by zero :
			if q.y >= 0.0:
				continue

			dir = direction # not 0 in order to make direction*d=1 if q.x=0
			if q.x > 0.0:
				dir = 1
			if q.x < 0.0:
				dir = -1
			Delta = P.dunkjump_speed*q.x/q.y
			Delta = Delta*Delta
			Delta += 2*P.gravity.y * q.x*q.x/q.y

			if Delta < 0.0 or direction*dir < best_direction:
				continue
			if direction*dir == best_direction and q.y > best_y:
				continue

			best_y = q.y
			best_dist2 = q.length_squared()
			best_direction = direction*dir

			selectable_node = b

	Selector.update_selection(2,selectable_node)
	Selector.update_selection(1,selectable_node)

#############################
func is_on_wall():
	# update_space_state()
	cast(rays[0])#fwd down
	return rays[0].result and P.is_on_wall()

func is_on_floor():
	# update_space_state()
	cast(rays[4])#down fwd
	cast(rays[5])#down bwd
	return (rays[4].result or rays[5].result)

func is_on_slope():
	# update_space_state()
	cast(rays[4])#down fwd
	cast(rays[5])#down bwd
	cast(rays[6])#slope fwd
	cast(rays[7])#slope bwd
	return (rays[4].result and not rays[5].result and rays[7].result) or \
			(rays[5].result and not rays[4].result and rays[6].result)

func can_wall_dive():
	# update_space_state()
	cast(rays[0])#fwd down
	if rays[0].result:
		cast(rays[1])#fwd up
		return !rays[1].result
	return false

func can_stand():
	# update_space_state()
	cast(rays[2])#up fwd
	cast(rays[3])#up bwd
	return !(rays[2].result or rays[3].result)

func can_dunkjump():
	# update_basket()
	return S.dunkjump_basket != null

func can_dunk():
	var selectables = $dunk_area.get_overlapping_areas()
	if !selectables.empty():
		var b = null
		S.dunk_basket = b
		var r = $dunk_area/CollisionShape2D.shape.radius
		var min_len_sq = r*r
		for i in range(selectables.size()):
			b = selectables[i].get_parent() # `get_parent` because we're
		# detecting the basket_area node
			var l2 = (b.position - P.position).length_squared()
			if b.can_receive_dunk and l2 < min_len_sq :
				S.dunk_basket = b
				min_len_sq = l2
		return S.dunk_basket != null
	return false

#############################

#func _draw():
#	for r in rays:
#		if r.result:#r.is_colliding():
#			draw_circle(r.result.position-P.position, 2, color)
#			draw_line(r.position, r.position+r.cast_to, color)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	update()

#############################
func set_flip_h(b):
	flip_h = b
	if b :
		rays = rays_flip
	else :
		rays = rays_not_flip
