extends Activable

export (float, EXP, 20, 2000) var speed_at_exit
export (float, EXP, 20, 2000) var speed_inside

enum PIPE_TYPE {TO_EXIT, TO_ENTRANCE, BOTH_SIDES}
export (PIPE_TYPE) var pipe_type = PIPE_TYPE.TO_EXIT

var inside_bodies = []
var path_follows = []

func _ready():
	add_to_group("holders")
	$Entrance.position = self.curve.get_point_position(0)
	$Exit.position = self.curve.get_point_position(self.curve.get_point_count()-1)

func _process(delta):
	var j = 0 # int because we're deleting nodes in a list we're browsing

	for i in range(inside_bodies.size()):
		var body = inside_bodies[i-j]
		var path_follow = path_follows[i-j]
		path_follow.offset += speed_inside * delta
		body.global_position = path_follow.global_position
		if path_follow.get_unit_offset() == 1.0:
			body.throw(path_follow.global_position,
						path_follow.transform.x * speed_at_exit)
			# transform.x is the direction (vec2D) of the pathfollow
			j += 1 # because we deleted a node in the list we're browsing

func remove_ball(i : int):
	assert(i < inside_bodies.size())
	inside_bodies.remove(i)
	path_follows[i].queue_free()
	path_follows.remove(i)

##############################

func _on_Entrance_body_entered(ball):
	if ball.is_in_group("balls") and \
		(pipe_type == PIPE_TYPE.TO_EXIT or pipe_type == PIPE_TYPE.BOTH_SIDES):
		
		for body in inside_bodies:
			if body == ball:
				print("ball already in pipe")
				return 1
			
		var new_path_follow : PathFollow2D = PathFollow2D.new()
		new_path_follow.offset = 0
		new_path_follow.loop = false
		self.add_child(new_path_follow)
		ball.pickup(self)
		
		inside_bodies.push_back(ball)
		path_follows.push_back(new_path_follow)

		print(ball.name+" enter the pipe: "+str(inside_bodies.size())+" bodies")

func _on_Exit_body_entered(body):
	pass # Replace with function body.

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
