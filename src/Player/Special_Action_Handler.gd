extends Node2D

onready var Player = get_parent()

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
	rays_not_flip = [$Ray_fwd_down, $Ray_fwd_up, $Ray_up_fwd, $Ray_up_bwd]
	rays_flip = [$Ray_fwd_down_f, $Ray_fwd_up_f, $Ray_up_bwd, $Ray_up_fwd]
	self.set_flip_h(get_parent().get_node("Sprite").flip_h)

func _draw():
	for r in rays:
		if r.result:#r.is_colliding():
			draw_circle(r.result.position-Player.position, 2, color)
			draw_line(r.position, r.position+r.cast_to, color)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	update()
	
func update_space_state():
	space_state = get_world_2d().direct_space_state

func cast(r): #we must have updated the space_state before
	r.result = space_state.intersect_ray(Player.position+r.position, Player.position+r.position+r.cast_to, 
	[Player], Player.collision_mask, true, false)

#############################
func is_on_wall():
	update_space_state()
	cast(rays[0])#fwd down
	return rays[0].result

func can_wall_dive():
	update_space_state()
	cast(rays[0])#fwd down
	if rays[0].result:
		cast(rays[1])#fwd up
		return !rays[1].result
	return false
		
func can_stand():
	update_space_state()
	cast(rays[2])#up fwd
	cast(rays[3])#up bwd
	return !(rays[2].result or rays[3].result)

#############################
func set_flip_h(b):
	flip_h = b
	if b :
		rays = rays_flip
	else :
		rays = rays_not_flip
