extends Area2D
# Ball pickup

onready var Player = get_parent()
onready var S = Player.get_node("Player_State")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_Ball_Handler_body_entered(body):
	print(body.name)
	if body.is_in_group("balls"):
		if body == S.released_ball:
			S.released_ball = null
			print("ignore")
			return
		if S.has_ball or S.is_shooting :
			pass
		else :
			pickup_ball(body)

func get_throw_position():
	# return the global position of the beginning of the throw, depending on the
	# position of the player and the flip value :
	if Player.flip_h :
		return Player.position + Vector2(-4.0,-6.0)
	else :
		return Player.position + Vector2(4.0,-6.0)

func set_has_ball_position():
	if Player.flip_h :
		S.active_ball.transform.origin.x = int(Player.position.x+0.5) - $Has_Ball_Position.position.x
		S.active_ball.transform.origin.y = int(Player.position.y+0.5) + $Has_Ball_Position.position.y
	else :
		S.active_ball.transform.origin = Player.position + $Has_Ball_Position.position

#####################

func pickup_ball(ball):
	print("pickup "+ball.name)
	S.has_ball = true
	S.active_ball = ball
	ball.pickup(Player)

	#TEMPORARY CONTROL NODE
	var ui = Player.get_node("Camera/Control/RichTextLabel")
	ui.clear()
	ui.add_text("Name : "+ball.name)
	ui.newline()
	ui.add_text("Ball mass  : "+str(ball.mass))
	ui.newline()
	ui.add_text("Ball frict : "+str(ball.friction))
	ui.newline()
	ui.add_text("Ball bounc : "+str(ball.bounce))
	ui.newline()
	ui.add_text("Ball posit : "+str(ball.position - Player.position))
	
func throw_ball(pos, speed):
	if S.has_ball and S.active_ball != null :
		print("throw "+S.active_ball.name)
		S.released_ball = S.active_ball
		S.active_ball.throw(pos, speed)
		yield(get_tree().create_timer(0.1), "timeout")
		S.released_ball = null
		
func shoot_ball(): # called by animation
	throw_ball(get_throw_position(), Player.ShootPredictor.shoot_vector_save + 0.5*S.velocity)
		

func free_ball(ball): # set out  active_ball and has_ball 
	# called by ball when thrown or deleted
	if S.has_ball and S.active_ball == ball:
		S.active_ball = null
		S.has_ball = false
		print("Player free_ball")
	elif S.has_ball :
		print("error, free_ball on other ball")
	else :
		print("error, free_ball but doesn't have ball")


func _physics_process(delta):
	if S.has_ball and S.active_ball != null :
		set_has_ball_position()
