extends Node2D

export (PackedScene) var ball = null # not yet used
export var jump_velocity = 500#pix/s
export (float) var cant_go_time = 0#s

# Called when the node enters the scene tree for the first time.
func _ready():
	pass



func _on_Area2D_body_entered(body):
	print("body_entered")
	if body.is_in_group("physicbodies"):
		print("balls")
		body.set_linear_velocity(jump_velocity*Vector2(0.0,-1.0).rotated(deg2rad(self.rotation_degrees)))
	elif body is Player:
		print("player")
		body.S.velocity = (jump_velocity*Vector2(0.0,-1.0).rotated(deg2rad(self.rotation_degrees)))
		if cant_go_time != 0:
			body.S.get_node("CanGoTimer").start(cant_go_time)
