extends Area2D
# Ball pickup

onready var Character = get_parent()
onready var S = Character.get_node("State")

export (float) var shoot_max_speed = 600.0 # kg*pix/s
var shoot_vector_save = Vector2() setget set_shoot_vector, get_shoot_vector

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
	print(body.name+" entering "+Character.name+" ballhandler area")
	if body.is_in_group("balls"):
		if body == S.released_ball:
			S.released_ball = null
			print("but "+body.name+" is ignored")
			return
		if S.has_ball or S.is_shooting :
			pass
		else :
			pickup_ball(body)

func get_throw_position():
	# return the global position of the beginning of the throw, depending on the
	# position of the player and the flip value :
	if Character.flip_h :
		return Character.position + Vector2(-4.0,-6.0)
	else :
		return Character.position + Vector2(4.0,-6.0)

func set_has_ball_position():
	if Character.flip_h :
		S.held_ball.transform.origin.x = int(Character.position.x+0.5) - $Has_Ball_Position.position.x
		S.held_ball.transform.origin.y = int(Character.position.y+0.5) + $Has_Ball_Position.position.y
	else :
		S.held_ball.transform.origin = Character.position + $Has_Ball_Position.position

#####################

func pickup_ball(ball):
	print(Character.name+" pickup "+ball.name)
	S.has_ball = true
	S.held_ball = ball
	ball.pickup(Character)

	#TEMPORARY CONTROL NODE
	var ui = Character.get_node("Camera/Control/RichTextLabel")
	ui.clear()
	ui.add_text("Name : "+ball.name)
	ui.newline()
	ui.add_text("Ball mass  : "+str(ball.mass))
	ui.newline()
	ui.add_text("Ball frict : "+str(ball.friction))
	ui.newline()
	ui.add_text("Ball bounc : "+str(ball.bounce))
	ui.newline()
	ui.add_text("Ball posit : "+str(ball.position - Character.position))

func throw_ball(pos, speed):
	if S.has_ball and S.held_ball != null :
		print(Character.name+" throw "+S.held_ball.name)
		S.released_ball = S.held_ball
		S.held_ball.throw(pos, speed)
		yield(get_tree().create_timer(0.1), "timeout")
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
