extends Area2D
# Ball pickup

onready var Player = get_parent()
onready var S = Player.get_node("State")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_Ball_Handler_body_entered(body):
	#print(body.name+" entering "+Player.name+" ballhandler area")
	if body.is_in_group("balls"):
		if body.is_reparenting():
			print(" - ballhandler "+body.name+" is ignored because reparenting")
			return # Workaround because of https://www.reddit.com/r/godot/comments/vjkaun/reparenting_node_without_removing_it_from_tree/
		if body == S.released_ball:
			S.released_ball = null
			print(" - but "+body.name+" is ignored because it was just released")
			return
		if S.has_ball or S.is_shooting :
			return
		else :
			pickup_ball(body)

func get_throw_position():
	# return the global position of the beginning of the throw, depending on the
	# position of the player and the flip value :
	if Player.flip_h :
		return Player.global_position + Vector2(-4.0,-6.0)
	else :
		return Player.global_position + Vector2(4.0,-6.0)

func set_has_ball_position():
	if Player.flip_h :
		S.active_ball.transform.origin.x = - $HasBallPosition.position.x
		S.active_ball.transform.origin.y = + $HasBallPosition.position.y
	else :
		S.active_ball.transform.origin = + $HasBallPosition.position

#####################

func pickup_ball(ball):
	print(Player.name+" pickup "+ball.name)
	print(str(Player.collision_layer)+" "+str(Player.collision_layer_save))
	S.has_ball = true
	S.active_ball = ball
	if Player.physics_enabled:
		print("Phys")
		Player.set_collision_layer_bit(10, true) #ball_wall collision layer
		Player.set_collision_mask_bit(10, true) #ball_wall collision layer
	Player.collision_layer_save |= 1<<10
	Player.collision_mask_save |= 1<<10
	print(str(Player.collision_layer)+" "+str(Player.collision_layer_save))
	ball.pickup(Player)

	#TEMPORARY CONTROL NODE
	var ui = Player.get_node("UI/MarginContainer/HBoxContainer/ColorRect/RichTextLabel")
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


func free_ball(ball): # set out  active_ball and has_ball
	# called by ball when thrown or deleted
	print(Player.name+" free_ball")
	print(str(Player.collision_layer)+" "+str(Player.collision_layer_save))
	if S.has_ball and S.active_ball == ball:
		S.active_ball = null
		S.has_ball = false
		if Player.physics_enabled:
			Player.set_collision_layer_bit(10, false)
			Player.set_collision_mask_bit(10, false) #ball_wall collision layer
		Player.collision_layer_save &= ~(1<<10)
		Player.collision_mask_save &= ~(1<<10)
		
		print(str(Player.collision_layer)+" "+str(Player.collision_layer_save))
		print(Player.name+" free_ball")
	elif S.has_ball :
		print("error, "+Player.name+" free_ball on other ball")
	else :
		print("error, "+Player.name+" free_ball but doesn't have ball")


func throw_ball(throw_global_position, speed):
	if S.has_ball and S.active_ball != null :
		print("throw "+S.active_ball.name)
		S.released_ball = S.active_ball
		S.active_ball.throw(throw_global_position, speed)
		# WARNING: Ugly but it works :
		yield(get_tree().create_timer(0.1), "timeout")
		S.released_ball = null

func shoot_ball(): # called by animation
	throw_ball(get_throw_position(), Player.ShootPredictor.shoot_vector_save + 0.5*S.velocity)

func _physics_process(delta):
	if S.has_ball and S.active_ball != null :
		set_has_ball_position()
