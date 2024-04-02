extends Node2D
class_name BasketHandler

@export var P: Player ## TODO rework this and use exports to states in order to use the appropriate data
@export var selectors : Selectors

@export var dunkjump_speed : float = -500.0 # pix/s
@export var dunkdash_speed : float = 600.0 # pix/s
@export var dunkdash_dist2_max : float = 180*180.0 # pix^2

@onready var dunkjump_area : Area2D = get_node("DunkjumpArea")
@onready var dunk_area : Area2D = get_node("DunkArea")

@onready var S = P.get_state_node()
@onready var dunkjump_criteria_bests = []
@onready var dunkdash_criteria_bests = []

var dunk_basket : Basket = null
var dunkdash_basket : Basket = null
var dunkjump_basket : Basket = null

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(dunkjump_area != null)
	assert(dunk_area != null)

####################################################################################################

# Those functions should not depend on S
func can_dunkjump():
	# update_basket()
	return dunkjump_basket != null

func can_dunkdash():
	return dunkdash_basket != null

func can_dunk():
	var selectables = dunk_area.get_overlapping_areas()
	if !selectables.is_empty():
		var b = null
		dunk_basket = b

		# TODO too much dependency for this. Maybe there is a area2D.get_shape function?:
		var r = GlobalMaths.get_max_radius(dunk_area.get_node("CollisionShape2D").shape)

		var min_len_sq = r*r
		for i in range(selectables.size()):
			b = selectables[i].get_parent() # `get_parent` because we're
		# detecting the basket_area node
			var l2 = (b.position - P.position).length_squared()
			if b is Basket and b.can_receive_dunk and l2 < min_len_sq :
				dunk_basket = b
				min_len_sq = l2
		return dunk_basket != null
	return false

####################################################################################################

func dunkjump_criteria_init():
	dunkjump_criteria_bests.clear()
	dunkjump_criteria_bests.push_back(0.0) # best_y
	dunkjump_criteria_bests.push_back(-2) # best_direction

## criteria to select the dunkjump target
## - q is basket_position - player_position
## - target_direction is the favorite direction
func dunkjump_criteria(q : Vector2, target_direction : int) -> bool:
	if q.y >= 0.0:
		return false
	var dir = target_direction # not 0 in order to make direction*d=1 if q.x=0
	if q.x > 0.0:
		dir = 1
	if q.x < 0.0:
		dir = -1
	var Delta = dunkjump_speed*q.x/q.y
	Delta = Delta*Delta
	Delta += 2*Global.default_gravity.y * q.x*q.x/q.y

	if Delta <= 0.0 or target_direction*dir < dunkjump_criteria_bests[1]:
		return false
	if target_direction*dir == dunkjump_criteria_bests[1] and q.y > dunkjump_criteria_bests[0]:
		return false

	dunkjump_criteria_bests[0] = q.y
	dunkjump_criteria_bests[1] = target_direction*dir
	return true

func dunkdash_criteria_init():
	dunkdash_criteria_bests.clear()
	dunkdash_criteria_bests.push_back(dunkdash_dist2_max) # best_dist2
	dunkdash_criteria_bests.push_back(-2) # best_direction

## criteria to select the dunkdash target
## - q is basket_position - player_position
## - target_direction is the favorite direction
func dunkdash_criteria(q : Vector2, target_direction : int) -> bool:
	var dir = target_direction # not 0 in order to make direction*d=1 if q.x=0
	if q.x > 0.0:
		dir = 1
	if q.x < 0.0:
		dir = -1
	if target_direction*dir < dunkdash_criteria_bests[1]:
		return false
	var lq2 = q.length_squared()
	if lq2 > dunkdash_dist2_max:
		return false
	if target_direction*dir == dunkdash_criteria_bests[1] and lq2 > dunkdash_criteria_bests[0]:
		return false

	dunkdash_criteria_bests[0] = lq2
	dunkdash_criteria_bests[1] = target_direction*dir
	return true

## TODO this function should maybe be elsewhere, with the appropriate dependencies
## Maybe in TargetHandler, or in S, making the link between BasketHandler and TargetHandler
func update_basket_selectors():
	var selectable_jump = null
	var selectable_dash = null

	var selectables = dunkjump_area.get_overlapping_areas()
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

	selectors.update_selection(Selectable.SelectionType.JUMP,selectable_jump)
	selectors.update_selection(Selectable.SelectionType.DASH,selectable_dash)
