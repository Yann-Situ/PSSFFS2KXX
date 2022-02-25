extends Node2D

var viewer_parameter = INF
onready var P = get_parent()
onready var shader = $ShootScreen/ShootScreenShader.material

func update_viewer_parameter(ball : Ball):
	var v = max(0.0000001, P.throw_impulse * ball.invmass)
	if ball.gravity != 0.0 :
		viewer_parameter = v*v/ball.gravity
	else:
		viewer_parameter = INF
	shader.set_shader_param("parameter", viewer_parameter)

func enable_screen_viewer():
	$ShootScreen/ShootScreenShader.visible = true
func disable_screen_viewer():
	$ShootScreen/ShootScreenShader.visible = false

func update_screen_viewer_position():
	var player_screen_pos = P.get_global_transform_with_canvas().origin
	shader.set_shader_param("throw_pos", player_screen_pos)
	
