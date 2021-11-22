extends Node2D

onready var Character = get_parent().get_parent()
onready var S = Character.get_node("State")

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
	self.set_flip_h(Character.flip_h)

#func _draw():
#	for r in rays:
#		if r.result:#r.is_colliding():
#			draw_circle(r.result.position-Character.position, 2, color)
#			draw_line(r.position, r.position+r.cast_to, color)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	update()

func update_space_state():
	space_state = get_world_2d().direct_space_state
	for r in rays:
		r.updated = false

func update_basket():
#	if S.dunkjump_basket != null:
#		S.dunkjump_basket.disable_contour()

	S.dunkjump_basket = null
	var baskets = $dunkjump_area.get_overlapping_areas()
	if !baskets.empty():
		# choose by priority baskets that are in direction_p, closest above player
		var b = baskets[0].get_parent() # `get_parent` because we're
		# detecting the basket_area node
		var q = (b.position-Character.position)
		var dir_sprite = 1
		if Character.flip_h:
			dir_sprite = -1
		var dir = dir_sprite # not 0 in order to make dir_sprite*d=1 if q.x=0
		if q.x > 0.0:
			dir = 1
		if q.x < 0.0:
			dir = -1
		var Delta = Character.dunk_speed*q.x/q.y
		Delta = Delta*Delta
		Delta += 2*Character.gravity * q.x*q.x/q.y
		var best_y = 0.0
		var best_dist2 = $dunkjump_area/CollisionShape2D.shape.radius
		best_dist2 *= 2 * best_dist2
		var best_direction = -2
		if Delta >= 0.0 and q.y < 0.0:
			S.dunkjump_basket = b
			best_y = q.y
			best_dist2 = q.length_squared()
			best_direction = dir_sprite*dir
		for i in range(1,baskets.size()):
			b = baskets[i].get_parent() # `get_parent` because we're
		# detecting the basket_area node
			q = (b.position-Character.position)
			if q.y >= 0.0:
				continue

			dir = dir_sprite
			if q.x > 0.0:
				dir = 1
			if q.x < 0.0:
				dir = -1
			Delta = Character.dunk_speed*q.x/q.y
			Delta = Delta*Delta
			Delta += 2*Character.gravity * q.x*q.x/q.y

			if Delta < 0.0 or dir_sprite*dir < best_direction:
				continue
			if dir_sprite*dir == best_direction and q.y > best_y:
				continue

			S.dunkjump_basket = b
			best_y = q.y
			best_dist2 = q.length_squared()
			best_direction = dir_sprite*dir

#	if S.dunkjump_basket != null:
#		S.dunkjump_basket.enable_contour()

func cast(r): #we must have updated the space_state before
	if not r.updated:
		r.result = space_state.intersect_ray(Character.position+r.position, \
			Character.position+r.position+r.cast_to, \
			[Character], Character.collision_mask, true, false)
		r.updated = true

#############################
func is_on_wall():
	# update_space_state()
	cast(rays[0])#fwd down
	return rays[0].result and Character.is_on_wall()

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
	var baskets = $dunk_area.get_overlapping_areas()
	if !baskets.empty():
		var b = baskets[0].get_parent() # `get_parent` because we're
		# detecting the basket_area node
		S.dunk_basket = b
		var min_len_sq = \
		(b.position - Character.position).length_squared()
		for i in range(1,baskets.size()):
			b = baskets[i].get_parent() # `get_parent` because we're
		# detecting the basket_area node
			var l2 = (b.position - Character.position).length_squared()
			if l2 < min_len_sq :
				S.dunk_basket = b
				min_len_sq = l2
		return true
	return false

#############################
func set_flip_h(b):
	flip_h = b
	if b :
		rays = rays_flip
	else :
		rays = rays_not_flip
