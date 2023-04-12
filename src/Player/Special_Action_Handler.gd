extends Node2D

@onready var P : Player = get_parent().get_parent() 
@onready var S = P.get_node("State")
@onready var Selector = get_parent().get_node("Selector")

@export var distaction = Vector2(8.1,0)
@export var color : Color = Color(1.0,0.3,0.1)
@export var flip_h : bool = false
var rays = []
var rays_flip = []
var rays_not_flip = []
var rays_res = []
var space_state : PhysicsDirectSpaceState2D

@onready var dunkjump_criteria_bests = []
@onready var dunkdash_criteria_bests = []

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
		var query = PhysicsRayQueryParameters2D.create(P.position+r.position, \
			P.position+r.position+r.target_position, P.collision_mask, [P])
		r.intersection_info = space_state.intersect_ray(query)
		r.result = r.intersection_info != {}
		r.updated = true

################################################################################

func dunkjump_criteria_init():
	dunkjump_criteria_bests.clear()
	dunkjump_criteria_bests.push_back(0.0) # best_y
	dunkjump_criteria_bests.push_back(-2) # best_direction

# criteria to select the dunkjump target
func dunkjump_criteria(q : Vector2, target_direction : int) -> bool:
	# q is basket_position - player_position
	# target_direction is the favorite direction
	if q.y >= 0.0:
		return false
	var dir = target_direction # not 0 in order to make direction*d=1 if q.x=0
	if q.x > 0.0:
		dir = 1
	if q.x < 0.0:
		dir = -1
	var Delta = P.dunkjump_speed*q.x/q.y
	Delta = Delta*Delta
	Delta += 2*P.default_gravity.y * q.x*q.x/q.y

	if Delta <= 0.0 or target_direction*dir < dunkjump_criteria_bests[1]:
		return false
	if target_direction*dir == dunkjump_criteria_bests[1] and q.y > dunkjump_criteria_bests[0]:
		return false

	dunkjump_criteria_bests[0] = q.y
	dunkjump_criteria_bests[1] = target_direction*dir
	return true

func dunkdash_criteria_init():
	dunkdash_criteria_bests.clear()
	dunkdash_criteria_bests.push_back(P.dunkdash_dist2_max) # best_dist2
	dunkdash_criteria_bests.push_back(-2) # best_direction

# criteria to select the dunkdash target
func dunkdash_criteria(q : Vector2, target_direction : int) -> bool:
	var dir = target_direction # not 0 in order to make direction*d=1 if q.x=0
	if q.x > 0.0:
		dir = 1
	if q.x < 0.0:
		dir = -1
	if target_direction*dir < dunkdash_criteria_bests[1]:
		return false
	var lq2 = q.length_squared()
	if lq2 > P.dunkdash_dist2_max:
		return false
	if target_direction*dir == dunkdash_criteria_bests[1] and lq2 > dunkdash_criteria_bests[0]:
		return false

	dunkdash_criteria_bests[0] = lq2
	dunkdash_criteria_bests[1] = target_direction*dir
	return true

func update_basket_selectors():
	var selectable_jump = null
	var selectable_dash = null

	var selectables = $dunkjump_area.get_overlapping_areas()
	if !selectables.is_empty():
		# choose by priority selectables that are in direction_p, closest above player
		var could_dunkjump = not S.get_node("ToleranceJumpFloorTimer").is_stopped() and \
			not S.is_non_cancelable and S.get_node("CanDunkjumpTimer").is_stopped()
		var could_dunkdash = not S.is_non_cancelable
		dunkjump_criteria_init()
		dunkdash_criteria_init()

		var target_direction = S.direction_p
		if target_direction == 0:
			if P.flip_h:
				target_direction = -1
			else :
				target_direction = 1

		for i in range(selectables.size()):
			var body = selectables[i]
			var q = (body.global_position-P.global_position)

			if body.is_jump_selectable and could_dunkjump and \
				dunkjump_criteria(q, target_direction):
				selectable_jump = body

			if body.is_dash_selectable and could_dunkdash and \
				dunkdash_criteria(q, target_direction):
				selectable_dash = body

	Selector.update_selection(Selectable.SelectionType.JUMP,selectable_jump)
	Selector.update_selection(Selectable.SelectionType.DASH,selectable_dash)

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
	return S.dunkjump_basket != null # S.dunkjump_basket is set by the Selector

func can_dunkdash():
	return S.dunkdash_basket != null  # S.dunkdash_basket is set by the Selector

func can_dunk():
	var selectables = $dunk_area.get_overlapping_areas()
	if !selectables.is_empty():
		var b = null
		S.dunk_basket = b
		var r = $dunk_area/CollisionShape2D.shape.radius
		var min_len_sq = r*r
		for i in range(selectables.size()):
			b = selectables[i].get_parent() # `get_parent` because we're
		# detecting the basket_area node
			var l2 = (b.position - P.position).length_squared()
			if b is Basket and b.can_receive_dunk and l2 < min_len_sq :
				S.dunk_basket = b
				min_len_sq = l2
		return S.dunk_basket != null
	return false

#############################

# func _draw():
# 	for r in rays:
# 		if r.result:#r.is_colliding():
# 			draw_circle(r.result.position-P.position, 2, color)
# 			draw_line(r.position, r.position+r.target_position, color)
#
# # Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	queue_redraw()

#############################
func set_flip_h(b):
	flip_h = b
	if b :
		rays = rays_flip
	else :
		rays = rays_not_flip
