extends Area2D
# Ball pickup
var S
# Called when the node enters the scene tree for the first time.
func _ready():
	S = get_parent().get_node("Player_State")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Ball_Handler_body_entered(body):
	print(body.name)
	if body.is_in_group("balls"):
		if S.has_ball or S.is_shooting :
			pass
		else :
			print("pickup "+body.name)
			S.has_ball = true
			S.active_ball = body
			body.disable_physics()

			#TEMPORARY CONTROL NODE
			var ui = get_parent().get_node("Camera/Control/RichTextLabel")
			ui.clear()
			ui.add_text("Name : "+body.name)
			ui.newline()
			ui.add_text("Ball mass  : "+str(body.mass))
			ui.newline()
			ui.add_text("Ball frict : "+str(body.friction))
			ui.newline()
			ui.add_text("Ball bounc : "+str(body.bounce))
			ui.newline()
			ui.add_text("Ball posit : "+str(body.position - get_parent().position))

func get_throw_position():
	# return the global position of the beginning of the throw, depending on the
	# position of the player and the flip value :
	if get_parent().get_node("Sprite").flip_h :
		return get_parent().position + Vector2(-4.0,-6.0)
	else :
		return get_parent().position + Vector2(4.0,-6.0)

func set_has_ball_position():
	if get_parent().get_node("Sprite").flip_h :
		S.active_ball.transform.origin.x = int(get_parent().position.x+0.5) - $Has_Ball_Position.position.x
		S.active_ball.transform.origin.y = int(get_parent().position.y+0.5) + $Has_Ball_Position.position.y
	else :
		S.active_ball.transform.origin = get_parent().position + $Has_Ball_Position.position

func throw_ball(): # called by animation
	if S.has_ball and S.active_ball != null :
		S.active_ball.enable_physics()
		S.active_ball.throw(get_throw_position(),
							get_parent().get_node("Shoot_predictor").shoot_vector_save + 0.5*S.velocity)
		print("throw ball at "+str(S.active_ball.position.x)+" vs "+str(position.x))
		free_ball()

func free_ball(): # set out  active_ball and has_ball
	if S.has_ball :
		S.active_ball = null
		S.has_ball = false
		print("free_ball")
	else :
		print("error, free_ball but doesn't have ball")


func _physics_process(delta):
	if S.has_ball and S.active_ball != null and not S.active_ball.physics_enabled:
		set_has_ball_position()
