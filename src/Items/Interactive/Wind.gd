tool
extends Node2D

export (Vector2) var speed = Vector2(200,0) setget set_speed # pix/s
export (Vector2) var rectangle_extents = Vector2(256,128) setget set_extents
export (float) var amplitude = 20.0  # pix/s
export (float) var frequence = 1.0  # 1/s
onready var direction = speed.normalized()

func set_speed(f : Vector2):
	speed = f
	direction = speed.normalized()
	if Engine.is_editor_hint():
		$Sprite.material.set_shader_param("velocity", 0.02*speed)
func set_extents(e : Vector2):
	rectangle_extents = e
	$Area2D/CollisionShape2D.shape.extents = rectangle_extents
	$Sprite.position = e
	$Sprite.scale = 2*e

func _ready():
	$Sprite.material.set_shader_param("velocity", -0.02*speed)

func _physics_process(delta):
	for body in $Area2D.get_overlapping_bodies():
		if body is PhysicBody or body is Player:
			var velocity = Vector2.ZERO
			var penetration = 0.0
			if body is Player:
				velocity = body.S.velocity
				penetration = 0.35
			else :
				velocity = body.linear_velocity
				penetration = body.penetration

			var force = Vector2.ZERO
			var speed_length = speed.dot(direction)+amplitude*sin(frequence*2*PI*OS.get_ticks_msec()*0.001)
			var effective_speed = min(speed_length-velocity.dot(direction), speed_length)
			if effective_speed > 0:
				force = 0.613*penetration*effective_speed*effective_speed*direction
				# F = Surface x Pression x Coeff_penetration
				# Pression = 0,613 x Vitesse^2
			body.add_force(self.name, force)


func _on_Area2D_body_entered(body):
	pass

func _on_Area2D_body_exited(body):
	if body.has_method("has_force") and body.has_method("remove_force"):
		if body.has_force(self.name):
			body.remove_force(self.name)
	else:
		push_warning("no method add_force in "+body.name)
