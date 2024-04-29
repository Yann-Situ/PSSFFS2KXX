@icon("res://assets/art/icons/target-bis-r-16.png")
extends Node2D
class_name ShootHandler

# @export var P: Player ## not necessary

@export_range(0.0,500) var aim_tau_radius : float = 100 ## I don't remember what is it for...
@export var throw_impulse : float = 600.0 ## kg.pix/s
@export var global_gravity_scale_TODO : float = 1.0 ## TODO implement extended shooter, with arbitrary forces/accel.

# @onready var S = P.get_state_node()
@onready var shader = $ShootScreen/ShootScreenShader.material

var viewer_parameter = INF
var vmax = INF
var vmax_2 = INF # (pix/s)^2

var target_position = Vector2.ZERO
var target_vmin_2 = 0.0 # (pix/s)^2

var effective_v = Vector2.ZERO# pix/s
var effective_v_2 = 0.0# (pix/s)^2

################################################################################

## used to be called in Aim.gd
func update_viewer_parameter(ball : Ball):
	# modify vmax and the viewer/shader parameter
	if ball == null:
		viewer_parameter = INF
		vmax = INF
		vmax_2 = INF
	else :
		vmax = max(0.0000001, throw_impulse * ball.invmass)
		vmax_2 = vmax*vmax
		if global_gravity_scale_TODO != 0.0 :
			viewer_parameter = vmax_2/(global_gravity_scale_TODO*Global.default_gravity.y)
		else:
			viewer_parameter = INF
	shader.set_shader_parameter("parameter", viewer_parameter)

func enable_screen_viewer():
	$ShootScreen/ShootScreenShader.visible = true
func disable_screen_viewer():
	$ShootScreen/ShootScreenShader.visible = false

func update_screen_viewer_position():
	var screen_position = get_global_transform_with_canvas().origin
	shader.set_shader_parameter("throw_position", screen_position)

################################################################################

func update_target(target : Vector2):
	target_position = target
	target_vmin_2 = (global_gravity_scale_TODO*Global.default_gravity.y)*(target.length() - target.y)


func can_shoot_to_target() -> bool:
	return target_vmin_2 <= vmax_2

func update_effective_cant_shoot(tau : float = 0.0, s = 0):
	var theta = lerp_angle(-PI/2, target_position.angle(), 0.5)
	effective_v_2 = vmax_2
	effective_v = GlobalMaths.polar_to_cartesian(Vector2(vmax, theta))

func update_effective_can_shoot(tau : float = 0.0, s = 0):
	# v is shortcut for velocity
	tau = clamp(tau, 0.0, 1.0)
	s = sign(s)
	var g = (global_gravity_scale_TODO*Global.default_gravity.y)
	var v_length = lerp(sqrt(target_vmin_2), vmax, tau)
	effective_v_2 = v_length*v_length

	var D = INF # g/v^2
	if effective_v_2 != 0.0 :
		D = g/effective_v_2
	var Q = D*target_position

	# due to float arithmetic, we need to force the following value to be positive :
	var temp = max(0.0, 1 - Q.x*Q.x + 2*Q.y)

	#print("%d %d", [g, temp, rad_to_deg(atan2(1 + s*sqrt(temp), Q.x))])
	effective_v = GlobalMaths.polar_to_cartesian(Vector2(v_length, -atan2(1 + s*sqrt(temp), Q.x)))

func tau_from_vector(vector : Vector2):
	# tau from the vector (mouse_position-ball)
	return abs(2*(smoothstep(-aim_tau_radius, aim_tau_radius, vector.y)-0.5))

func s_from_vector(vector : Vector2):
	# s from the vector (mouse_position-ball)
	return sign(vector.y)
