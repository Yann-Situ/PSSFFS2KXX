@tool
extends Activable

@export_range(20, 2000) var speed_at_exit : float
@export_range(20, 2000) var speed_inside : float

enum PIPE_TYPE {TO_EXIT, TO_ENTRANCE, BOTH_SIDES}
@export var pipe_type : PIPE_TYPE = PIPE_TYPE.TO_EXIT

enum PIPE_Z {BACK, FRONT}
@export var pipe_z : PIPE_Z = PIPE_Z.BACK

var inside_bodies = []
var path_follows = []

func _ready():
	if pipe_z == PIPE_Z.BACK:
		self.z_index = Global.z_indices["background_4"]
	elif pipe_z == PIPE_Z.FRONT:
		self.z_index = Global.z_indices["foreground_1"]
	add_to_group("holders")

	$Entrance.position = self.curve.get_point_position(0)
	update_entrance_rotation()
	update_entrance_sprite()

func _process(delta):
	if !self.activated :
		return

	var j = 0 # int because we're deleting nodes in a list we're browsing
	for i in range(inside_bodies.size()):
		var body = inside_bodies[i-j]
		var path_follow = path_follows[i-j]
		path_follow.progress += speed_inside * delta
		body.global_position = path_follow.global_position
		if path_follow.get_progress_ratio() == 1.0:
			body.throw(path_follow.global_position,
						path_follow.transform.x * speed_at_exit)
			# note that throw also call self.free_ball and remove it from the
			# inside_bodies list

			# transform.x is the direction (vec2D) of the pathfollow
			j += 1 # because we deleted a node in the list we're browsing

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
	if self.activated and ball.is_in_group("balls") and \
		(pipe_type == PIPE_TYPE.TO_EXIT or pipe_type == PIPE_TYPE.BOTH_SIDES):
		# if ball.is_reparenting():
		# 	print(" - pipe "+ball.name+" is ignored because reparenting")
		# 	return # Workaround because of https://www.reddit.com/r/godot/comments/vjkaun/reparenting_node_without_removing_it_from_tree/

		for body in inside_bodies:
			if body == ball:
				print(ball.name+" already in pipe")
				return

		var new_path_follow : PathFollow2D = PathFollow2D.new()
		new_path_follow.progress = 0
		new_path_follow.loop = false
		self.add_child(new_path_follow)
		# WARNING : due to the issue in Ball.gd func change_holder, this part can freeze/crash.
		# https://www.reddit.com/r/godot/comments/vjkaun/reparenting_node_without_removing_it_from_tree/
		inside_bodies.push_back(ball)
		ball.pickup(self)
		ball.z_index = z_index-1
		path_follows.push_back(new_path_follow)

		print(ball.name+" enter the pipe: "+str(inside_bodies.size())+" bodies")


################################################################################
# For `holders` group
func free_ball(ball): # set out  active_ball and has_ball
	# called by ball when thrown or deleted
	var i = 0
	for body in inside_bodies:
		if body == ball:
			print("pipe free_ball("+ball.name+")")
			remove_ball(i)
		i += 1

func remove_ball(i : int):
	assert(i < inside_bodies.size())
	inside_bodies[i].z_index = Global.z_indices["ball_0"]
	inside_bodies.remove_at(i)
	path_follows[i].queue_free()
	path_follows.remove_at(i)

################################################################################

func on_enable():
	# Annoying problem on export variables in tool with setter that calle a node :
	#[https://github.com/godotengine/godot-proposals/issues/325]
	if is_inside_tree():
		update_entrance_sprite()
		for ball in $Entrance/Area3D.get_overlapping_bodies():
			_on_Area_body_entered(ball)

func on_disable():
	if is_inside_tree():
		update_entrance_sprite()
