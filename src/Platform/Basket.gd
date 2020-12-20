extends Node2D

export var color1 = Color(0.8,0.5,0.1,0.5)
export var color2 = Color(0.9,0.1,0.3,1.0)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _draw():
	draw_circle($dunk_area/CollisionShape2D.position, $dunk_area/CollisionShape2D.shape.radius, color1)
	#draw_line(position+$basket_area/CollisionShape2D.shape.a, position+$basket_area/CollisionShape2D.shape.b, color2)
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()

func _on_basket_area_body_entered(body):
	print("basket :"+body.name)
	if body.name.substr(0,4) == "Ball":
		if body.linear_velocity.y > 0.0:
			print("GOOOAL!")
