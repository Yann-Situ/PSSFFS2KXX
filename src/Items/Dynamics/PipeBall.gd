@tool
extends Activable

@export_range(20, 2000) var speed_at_exit : float
@export_range(20, 2000) var speed_inside : float

enum PIPE_TYPE {TO_EXIT, TO_ENTRANCE, BOTH_SIDES}
@export var pipe_type : PIPE_TYPE = PIPE_TYPE.TO_EXIT

enum PIPE_Z {BACK, FRONT}
@export var pipe_z : PIPE_Z = PIPE_Z.BACK

@onready var ball_holder : BallHolder = $BallHolder
#var inside_bodies = []
var path_follows = {}

func _ready():
	if pipe_z == PIPE_Z.BACK:
		self.z_index = Global.z_indices["background_4"]
	elif pipe_z == PIPE_Z.FRONT:
		self.z_index = Global.z_indices["foreground_1"]
	add_to_group("holders")

	$Entrance.position = self.curve.get_point_position(0)
	update_entrance_rotation()
	update_entrance_sprite()


func update_entrance_sprite():
	if self.activated :
		$Entrance/Sprite2D.set_animation("active")
		$Entrance/Particles.emitting = true
	else :
		$Entrance/Sprite2D.set_animation("not_active")
		$Entrance/Particles.emitting = false

func update_entrance_rotation():
	if self.curve.get_point_count() >= 2:
		var vec_direction = self.curve.get_point_position(0) - \
			self.curve.get_point_position(1)
		$Entrance.set_rotation(Vector2.UP.angle_to(vec_direction))

##############################

func _on_Area_body_entered(ball):
	if self.activated and ball is Ball and \
		(pipe_type == PIPE_TYPE.TO_EXIT or pipe_type == PIPE_TYPE.BOTH_SIDES):
		ball.pick(ball_holder)

func _on_ball_holder_picking(ball):
	var new_path_follow : PathFollow2D = PathFollow2D.new()
	new_path_follow.progress = 0
	new_path_follow.loop = false
	self.add_child(new_path_follow)
	path_follows[ball] = new_path_follow

	print(ball.name+" enter the pipe: "+str(ball_holder.held_balls.size())+" bodies")

func _on_ball_holder_physics_processing_ball(ball : Ball, delta):
	assert(path_follows.has(ball))
	if !self.activated :
		return
	var path_follow : PathFollow2D = path_follows[ball]
	path_follow.progress += speed_inside * delta
	ball.global_position = path_follow.global_position
	if path_follow.get_progress_ratio() == 1.0:
		ball.throw(path_follow.global_position,
					path_follow.transform.x * speed_at_exit)
		# note that throw also call self.free_ball and remove it from the
		# ball_holder.held_balls list

		# transform.x is the direction (vec2D) of the pathfollow

func _on_ball_holder_releasing(ball : Ball):
	assert(path_follows.has(ball))
	path_follows[ball].call_deferred("queue_free")
	path_follows.erase(ball)

################################################################################

func on_enable():
	# Annoying problem on export variables in tool with setter that calle a node :
	#[https://github.com/godotengine/godot-proposals/issues/325]
	if is_inside_tree():
		update_entrance_sprite()
		for ball in $Entrance/Area2D.get_overlapping_bodies():
			_on_Area_body_entered(ball)

func on_disable():
	if is_inside_tree():
		update_entrance_sprite()
