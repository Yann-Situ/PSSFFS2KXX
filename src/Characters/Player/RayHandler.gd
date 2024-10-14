@icon("res://assets/art/icons/ray-r-16.png")
extends Node2D
class_name RayHandler

@export var P: Player ## P is only used for position

var rays = []
var rays_flip = []
var rays_not_flip = []
var rays_res = []
var space_state : PhysicsDirectSpaceState2D

# Called when the node enters the scene tree for the first time.
func _ready():
	rays_not_flip = [$Ray_fwd_down, $Ray_fwd_up, $Ray_up_fwd, $Ray_up_bwd, \
		$Ray_down_fwd, $Ray_down_bwd, $Ray_slope_fwd, $Ray_slope_bwd]
	#rays_flip = [$Ray_fwd_down_f, $Ray_fwd_up_f, $Ray_up_bwd, $Ray_up_fwd, \
		#$Ray_down_bwd, $Ray_down_fwd, $Ray_slope_bwd, $Ray_slope_fwd]
	rays = rays_not_flip
	update_space_state()

func update_space_state(): # TODO change the following behavior : update_space_state() need to be called before
	space_state = get_world_2d().direct_space_state
	for r in rays:
		r.updated = false

func cast(r): #we must have updated the space_state before
	if not r.updated:
		## WARNING in the following line we use here P.collision_mask instead of r.collision mask 
		# in order to take into account the changes in the playerwall layer
		var target_position = r.target_position * P.flipper.scale # vector component multiplication
		var query = PhysicsRayQueryParameters2D.create(r.global_position, \
			r.global_position + target_position, P.collision_mask, [P])
		r.intersection_info = space_state.intersect_ray(query)
		r.result = r.intersection_info != {}
		r.updated = true

################################################################################

func is_on_wall():
	# update_space_state()
	cast(rays[0])#fwd down
	return rays[0].result and P.is_on_wall()

func is_on_floor():
	# update_space_state()
	cast(rays[4])#down fwd
	cast(rays[5])#down bwd
	return (rays[4].result or rays[5].result)
	
func is_above_floor():
	# update_space_state()
	cast(rays[6])#down fwd
	cast(rays[7])#down bwd
	return (rays[6].result or rays[7].result)

## WARNING not used yet
func is_on_slope():
	# update_space_state()
	cast(rays[4])#down fwd
	cast(rays[5])#down bwd
	cast(rays[6])#slope fwd
	cast(rays[7])#slope bwd
	return (rays[4].result and not rays[5].result and rays[7].result) or \
			(rays[5].result and not rays[4].result and rays[6].result)

## WARNING not used yet
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

