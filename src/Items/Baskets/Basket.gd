extends Node2D

export var color1 = Color(0.8,0.5,0.1,0.5)
export var color2 = Color(0.9,0.1,0.3,1.0)
export var speed_ball_threshold = 380 #velocity value
onready var start_position = global_position

func _ready():
	self.z_index = Global.z_indices["foreground_1"]

# Should be in any items that can be picked/placed :
func set_start_position(posi):
	start_position = posi
	global_position = posi

func _draw():
	pass
	#draw_line(position+$basket_area/CollisionShape2D.shape.a, position+$basket_area/CollisionShape2D.shape.b, color2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()

func _on_basket_area_body_entered(body):
	#print("basket :"+body.name)
	if body.is_in_group("balls"):
		if body.linear_velocity.y > 0.0:
			print(body.linear_velocity.y)
			goal(body)

func dunk():
	print("DUUUNK!")
	$CPUParticles2D.initial_velocity = 80.0
	$CPUParticles2D.amount = 60
	$CPUParticles2D.restart()
	Global.camera.screen_shake(0.3,5)

func goal(body):
	print("GOOOAL!")
	if body.linear_velocity.y > speed_ball_threshold:
		$CPUParticles2D.initial_velocity = 60.0
		$CPUParticles2D.amount = 40
		Global.camera.screen_shake(0.3,5)
	else :
		$CPUParticles2D.initial_velocity = 30.0
		$CPUParticles2D.amount = 20
	$CPUParticles2D.restart()

func enable_contour():
	get_material().set_shader_param("activated", true)

func disable_contour():
	get_material().set_shader_param("activated", false)
