extends Node2D

export (PackedScene) var ball = null
export var jump_velocity = 500#pix/s

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
		body.S.last_walljump = body.S.time # hack
