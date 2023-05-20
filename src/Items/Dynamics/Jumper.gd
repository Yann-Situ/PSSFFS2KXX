extends Node2D

## not yet used
#@export var ball : PackedScene = null
## instant vertical velocity when a body enter the area
@export var jump_velocity = 500#pix/s
@export var cant_go_time : float = 0#s
var jump_direction = Vector2.UP

func _set(property, value):
	match property:
		"rotation":
			rotation = value
			jump_direction = Vector2.UP.rotated(rotation)

# Called when the node enters the scene tree for the first time.
func _ready():
	self.z_index = Global.z_indices["foreground_1"]

func _on_Area2D_body_entered(body):
	if body.is_in_group("situbodies"):
		# first delete the normal velocity of the body
		var velocity_change = Vector2.ZERO
		velocity_change -= body.linear_velocity.dot(jump_direction)*jump_direction
		# then apply the jump impulse
		velocity_change += jump_velocity*jump_direction
		body.add_impulse(body.mass*velocity_change)
		# TODO: add impulse does not modify immediatly the velocity.
		# As a result, two or more jumpers can be triggered by a ball before updating velocity,
		# resulting in applying multiple jump_velocity (big jumps)
		# 
		$AnimationPlayer.stop(true)
		$AnimationPlayer.play("jump")
	elif body.is_in_group("characters"):
		# first delete the normal velocity of the body
		var velocity_change = Vector2.ZERO
		velocity_change -= body.S.velocity.dot(jump_direction)*jump_direction
		# then apply the jump impulse
		velocity_change += jump_velocity*jump_direction
		body.add_impulse(body.mass*velocity_change)
		if cant_go_time > 0:
			body.S.get_node("CanGoTimer").start(cant_go_time)
		$AnimationPlayer.stop(true)
		$AnimationPlayer.play("jump")
