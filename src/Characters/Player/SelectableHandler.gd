@icon("res://assets/art/icons/select-r-16.png")
extends Node2D
class_name SelectableHandler
## Handle selectables (mainly used for baskets and dunkjump, dunkdash, dunk and shoot)
## depending on custom criterias (mostly just distance comparison).

@export var selectable_area : Area2D
## should be big enough to contain the baskets that are reachable by dunks,
## dunkjumps and dunkdashes # = get_node("DunkjumpArea")

@export var dunkjump_speed : float = -500.0 ## pix/s
@export var dunkdash_speed : float = 600.0 ## pix/s
@export var dunkdash_dist_max : float = 180 ## pix
@export var dunk_dist_max : float = 56 ## pix
@export var dunk_vertical_offset : float = -10 ## pix
@export var shoot_dist_max : float = 750 ## pix ; should be set depending on the ball, probably at pickup

@onready var dunkdash_dist2_max : float = dunkdash_dist_max * dunkdash_dist_max # pix^2
@onready var dunk_dist2_max : float = dunk_dist_max * dunk_dist_max # pix^2
@onready var shoot_dist2_max : float = shoot_dist_max * shoot_dist_max # pix^2

@onready var dunkjump_criteria_bests = []
@onready var dunkdash_criteria_bests = []
@onready var dunk_criteria_bests = []
@onready var shoot_criteria_bests = []

var selectable_dunkjump : Selectable = null
var selectable_dunkdash : Selectable = null
var selectable_dunk : Selectable = null
var selectable_shoot : Selectable = null

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(selectable_area != null)

####################################################################################################

# Those functions should not depend on S
func has_selectable_dunkjump():
	# update_selectable()
	return selectable_dunkjump != null

func has_selectable_dunkdash():
	return selectable_dunkdash != null

func has_selectable_dunk():
	return selectable_dunk != null

func has_selectable_shoot():
	return selectable_shoot != null

####################################################################################################

# DUNK
func dunk_criteria_init():
	dunk_criteria_bests.clear()
	dunk_criteria_bests.push_back(dunk_dist2_max) # best_dist2
	dunk_criteria_bests.push_back(-2) # best_direction

## criteria to select the dunk target
## - q is basket_position - player_position
## - target_direction is the favorite direction
func dunk_criteria(q : Vector2, target_direction : int) -> bool:
	var dir = target_direction # not 0 in order to make target_direction*dir=1 if q.x=0
	if q.x > 0.0:
		dir = 1
	if q.x < 0.0:
		dir = -1
	q.y += dunk_vertical_offset
	if target_direction*dir < dunk_criteria_bests[1]:
		return false
	var lq2 = q.length_squared()
	if lq2 > dunk_dist2_max:
		return false
	if target_direction*dir == dunk_criteria_bests[1] and lq2 > dunk_criteria_bests[0]:
		return false

	dunk_criteria_bests[0] = lq2
	dunk_criteria_bests[1] = target_direction*dir
	return true

# SHOOT
func shoot_criteria_init():
	shoot_criteria_bests.clear()
	shoot_criteria_bests.push_back(shoot_dist2_max) # best_dist2
	shoot_criteria_bests.push_back(-2) # best_direction

## criteria to select the shoot target
## - q is basket_position - player_position
## - target_direction is the favorite direction
func shoot_criteria(q : Vector2, target_direction : int) -> bool:
	var dir = target_direction # not 0 in order to make target_direction*dir=1 if q.x=0
	if q.x > 0.0:
		dir = 1
	if q.x < 0.0:
		dir = -1
	if target_direction*dir < shoot_criteria_bests[1]:
		return false
	var lq2 = q.length_squared()
	if lq2 > shoot_dist2_max:
		return false
	if target_direction*dir == shoot_criteria_bests[1] and lq2 > shoot_criteria_bests[0]:
		return false

	shoot_criteria_bests[0] = lq2
	shoot_criteria_bests[1] = target_direction*dir
	return true

# DUNKJUMP
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

# DUNKDASH
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

################################################################################

## target_direction_x should not be 0
func update_selectables(target_direction_x : int):
	if target_direction_x == 0:
		target_direction_x = 1

	selectable_dunkjump = null
	selectable_dunkdash = null
	selectable_dunk = null
	selectable_shoot = null

	# WARNING selectable_area could be null if something bad happens:
	if !selectable_area:
		push_error("selectable_area is null")
		return
	var selectables = selectable_area.get_overlapping_areas()
	if selectables.is_empty():
		return

	dunkjump_criteria_init()
	dunkdash_criteria_init()
	dunk_criteria_init()
	shoot_criteria_init()

	for i in range(selectables.size()):
		var selectable = selectables[i]
		var q = (selectable.global_position-global_position)

		if selectable.is_jump_selectable and dunkjump_criteria(q, target_direction_x):
			selectable_dunkjump = selectable

		if selectable.is_dash_selectable and dunkdash_criteria(q, target_direction_x):
			selectable_dunkdash = selectable

		if selectable.is_dunk_selectable and dunk_criteria(q, target_direction_x):
			selectable_dunk = selectable

		if selectable.is_shoot_selectable and shoot_criteria(q, target_direction_x):
			selectable_shoot = selectable
