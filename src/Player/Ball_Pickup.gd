extends Area2D
# Ball pickup
var S
var pla
# Called when the node enters the scene tree for the first time.
func _ready():
	S = get_parent().get_node("Player_State")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Ball_Pickup_body_entered(body):
	print(body.name)
	if body.name=='Ball':
		if S.has_ball :
			pass
		else :
			print("pickup "+body.name)
			S.has_ball = true
			S.active_ball = body
			body.disable_physics()

func free_ball():
	if S.has_ball :
		print("free ball at "+str(S.active_ball.position.x)+" vs "+str(get_parent().position.x))
		S.active_ball = null
		S.has_ball = false
		print("free_ball")
	else :
		print("error, free_ball but doesn't have ball")
	
