extends Node2D

@export var ball : PackedScene = null # not yet used
@export var jump_velocity = 500#pix/s
@export var cant_go_time : float = 0#s

# Called when the node enters the scene tree for the first time.
func _ready():
	self.z_index = Global.z_indices["foreground_1"]

func _on_Area2D_body_entered(body):
	if body.is_in_group("physicbodies"):
		body.set_linear_velocity(jump_velocity*Vector2(0.0,-1.0).rotated(deg_to_rad(self.rotation_degrees)))
		$AnimationPlayer.stop(true)
		$AnimationPlayer.play("jump")
	elif body.is_in_group("characters"):
		body.S.velocity = (jump_velocity*Vector2(0.0,-1.0).rotated(deg_to_rad(self.rotation_degrees)))
		if cant_go_time != 0:
			body.S.get_node("CanGoTimer").start(cant_go_time)
		$AnimationPlayer.stop(true)
		$AnimationPlayer.play("jump")
