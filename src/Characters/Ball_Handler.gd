extends Area2D
# Ball pickup

@onready var Character = get_parent()
@onready var S = Character.get_node("State")

@export var shoot_max_speed : float = 1000.0 # kg*pix/s
var shoot_vector_save = Vector2() : get = get_shoot_vector, set = set_shoot_vector

################## Shoot features

func set_shoot_vector(v):
	shoot_vector_save = clamp(v.length(), 0.0, shoot_max_speed)*v.normalized()
func get_shoot_vector():
	return shoot_vector_save

##################

func _ready():
	pass

################## pickup and throw

func _on_Ball_Handler_body_entered(body):
	#print(body.name+" entering "+Character.name+" ballhandler area")
	if Character.physics_enabled and body.is_in_group("balls"):
		if body.is_reparenting():
			print(" - ballhandler "+body.name+" is ignored because reparenting")
			return # Workaround because of https://www.reddit.com/r/godot/comments/vjkaun/reparenting_node_without_removing_it_from_tree/
		if body == S.released_ball:
			S.released_ball = null
			print(" - but "+body.name+" is ignored")
			return
		if S.has_ball or S.is_shooting :
			pass
		else :
			pickup_ball(body)

func get_throw_position():
	# return the global position of the beginning of the throw, depending on the
	# position of the player and the flip value :
	if Character.flip_h :
		return Character.global_position + Vector2(-4.0,-6.0)
	else :
		return Character.global_position + Vector2(4.0,-6.0)

func set_has_ball_position():
#	if Character.flip_h :
#		S.held_ball.global_position.x = int(Character.global_position.x+0.5) - $Has_Ball_Position.position.x
#		S.held_ball.global_position.y = int(Character.global_position.y+0.5) + $Has_Ball_Position.position.y
#	else :
#		S.held_ball.global_position = Character.global_position + $Has_Ball_Position.global_position
	if Character.flip_h :
		S.held_ball.position.x = - $Has_Ball_Position.position.x
		S.held_ball.position.y = + $Has_Ball_Position.position.y
	else :
		S.held_ball.position = + $Has_Ball_Position.position

#####################

func pickup_ball(ball):
	print(Character.name+" pickup "+ball.name)
	S.has_ball = true
	S.held_ball = ball
	ball.pickup(Character)

func throw_ball(throw_global_position, momentum):
	if S.has_ball and S.held_ball != null :
		print(Character.name+" throw "+S.held_ball.name)
		S.released_ball = S.held_ball
		S.held_ball.throw(throw_global_position, 1.0/S.held_ball.mass * momentum)
		await get_tree().create_timer(0.1).timeout
		S.released_ball = null

func shoot_ball(): # called by animation
	throw_ball(get_throw_position(), get_shoot_vector())


func free_ball(ball): # set out  held_ball and has_ball
	# called by ball when thrown or deleted
	if S.has_ball and S.held_ball == ball:
		S.held_ball = null
		S.has_ball = false
		print(Character.name+" free_ball")
	elif S.has_ball :
		print("error, "+Character.name+" free_ball on other ball")
	else :
		print("error, "+Character.name+" free_ball but doesn't have ball")


func _physics_process(delta):
	if S.has_ball and S.held_ball != null :
		set_has_ball_position()
