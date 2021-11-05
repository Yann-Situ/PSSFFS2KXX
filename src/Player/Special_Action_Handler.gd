extends Node2D

onready var Player = get_parent().get_parent()
onready var S = Player.get_node("Player_State")

export var distaction = Vector2(8.1,0)
export var color = Color(1.0,0.3,0.1)
export (bool) var flip_h = false
var rays = []
var rays_flip = []
var rays_not_flip = []
var rays_res = []
var space_state

var dunkjump_y_lim = 10
var dunk_dist_squared = 32*32

# Called when the node enters the scene tree for the first time.
func _ready():
	rays_not_flip = [$Ray_fwd_down, $Ray_fwd_up, $Ray_up_fwd, $Ray_up_bwd, \
		$Ray_down_fwd, $Ray_down_bwd, $Ray_slope_fwd, $Ray_slope_bwd]
	rays_flip = [$Ray_fwd_down_f, $Ray_fwd_up_f, $Ray_up_bwd, $Ray_up_fwd, \
		$Ray_down_bwd, $Ray_down_fwd, $Ray_slope_bwd, $Ray_slope_fwd]
	self.set_flip_h(Player.flip_h)

func _draw():
	for r in rays:
		if r.result:#r.is_colliding():
			draw_circle(r.result.position-Player.position, 2, color)
			draw_line(r.position, r.position+r.cast_to, color)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()
	
func update_space_state():
	space_state = get_world_2d().direct_space_state
	for r in rays:
		r.updated = false
	
func update_basket():
	if S.selected_basket != null:
		S.selected_basket.disable_contour()
		
	S.selected_basket = null
	var baskets = $dunk_area.get_overlapping_areas()
	if !baskets.empty():
		# choose by priority baskets that are in direction_p, closest above player
		var b = baskets[0].get_parent()
		var q = (b.position-Player.position)
		var dir_sprite = 1
		if Player.flip_h:
			dir_sprite = -1
		var dir = dir_sprite # not 0 in order to make dir_sprite*d=1 if q.x=0
		if q.x > 0.0:
			dir = 1
		if q.x < 0.0:
			dir = -1
		var Delta = Player.dunk_speed*q.x/q.y
		Delta = Delta*Delta
		Delta += 2*Player.gravity * q.x*q.x/q.y
		var best_y = dunkjump_y_lim
		var best_dist2 = 2 * $dunk_area/CollisionShape2D.shape.radius
		var best_direction = -2
		if Delta >= 0:
			S.selected_basket = b
			best_y = q.y
			best_dist2 = q.length_squared()
			best_direction = dir_sprite*dir
		for i in range(1,baskets.size()):
			b = baskets[i].get_parent()
			q = (b.position-Player.position)
			dir = dir_sprite
			if q.x > 0.0:
				dir = 1
			if q.x < 0.0:
				dir = -1
			Delta = Player.dunk_speed*q.x/q.y
			Delta = Delta*Delta
			Delta += 2*Player.gravity * q.x*q.x/q.y
			
			if best_dist2 < dunk_dist_squared:
				continue
			
			if q.length_squared() > dunk_dist_squared :
				if Delta < 0 or \
					dir_sprite*dir < best_direction:
					continue
				
				if dir_sprite*dir == best_direction and \
					q.y > best_y:
					continue
				
			S.selected_basket = b
			best_y = q.y
			best_dist2 = q.length_squared()
			best_direction = dir_sprite*dir
	
	if S.selected_basket != null:
		S.selected_basket.enable_contour()
		
func cast(r): #we must have updated the space_state before
	if not r.updated:
		r.result = space_state.intersect_ray(Player.position+r.position, \
			Player.position+r.position+r.cast_to, \
			[Player], Player.collision_mask, true, false)
		r.updated = true

#############################
func is_on_wall():
	# update_space_state()
	cast(rays[0])#fwd down
	return rays[0].result

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
	return S.selected_basket != null
	
func can_dunk():
	# update_basket()
	var b = S.selected_basket
	if b != null:
		var q = (b.position-Player.position)
		return q.y > -5 and q.y < 20 and abs(q.x) < 32
		#print(S.selected_basket)
	return false

#############################
func set_flip_h(b):
	flip_h = b
	if b :
		rays = rays_flip
	else :
		rays = rays_not_flip
