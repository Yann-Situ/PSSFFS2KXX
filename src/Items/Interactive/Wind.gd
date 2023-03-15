# @tool # some temporary tool problems
extends Node2D

@export var speed : Vector2 = Vector2(200,0) :
	set = set_velocity # pix/s
@export var rectangle_extents : Vector2 = Vector2(256,128) : set = set_extents
@export var amplitude : float = 20.0  # pix/s
@export var frequence : float = 1.0  # 1/s
@onready var direction = speed.normalized()

func set_velocity(f : Vector2):
	speed = f
	direction = speed.normalized()
	if Engine.is_editor_hint():
		$Sprite2D.material.set_shader_parameter("velocity", 0.02*speed)
func set_extents(e : Vector2):
	rectangle_extents = e
	$Area2D/CollisionShape2D.shape.size = rectangle_extents
	$Sprite2D.position = e
	$Sprite2D.scale = 2*e

func _ready():
	$Sprite2D.material.set_shader_parameter("velocity", -0.02*speed)

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
			var speed_length = speed.dot(direction)+amplitude*sin(frequence*2*PI*Time.get_ticks_msec()*0.001)
			var effective_speed = min(speed_length-velocity.dot(direction), speed_length)
			if effective_speed > 0:
				force = 0.613*penetration*effective_speed*effective_speed*direction
				# F = Surface x Pression x Coeff_penetration
				# Pression = 0,613 x Vitesse^2
			body.apply_force(force, self.name)


func _on_Area2D_body_entered(body):
	pass

func _on_Area2D_body_exited(body):
	if body.has_method("has_force") and body.has_method("remove_force"):
		if body.has_force(self.name):
			body.remove_force(self.name)
	else:
		push_warning("no method apply_force in "+body.name)
