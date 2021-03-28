extends Node2D

export var color1 = Color(0.8,0.5,0.1,0.5)
export var color2 = Color(0.9,0.1,0.3,1.0)
export var speed_ball_threshold = 380 #velocity value
onready var start_position = global_position

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Should be in any items that can be picked/placed :
func set_start_position(posi):
	start_position = posi
	global_position = posi

func _draw():
	draw_circle($dunk_area/CollisionShape2D.position, $dunk_area/CollisionShape2D.shape.radius, color1)
	#draw_line(position+$basket_area/CollisionShape2D.shape.a, position+$basket_area/CollisionShape2D.shape.b, color2)
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()

func _on_basket_area_body_entered(body):
	print("basket :"+body.name)
	if body is Ball:
		if body.linear_velocity.y > 0.0:
			print("GOOOAL!")
			print(body.linear_velocity.y)
			goal(body)
			
func goal(body):
	if body.linear_velocity.y > speed_ball_threshold:
		$CPUParticles2D.initial_velocity = 60.0
		$CPUParticles2D.amount = 40
		Global.camera.screen_shake(0.3,5)
	else :
		$CPUParticles2D.initial_velocity = 30.0
		$CPUParticles2D.amount = 20
	$CPUParticles2D.restart()
	#$CPUParticles2D.emitting = true
