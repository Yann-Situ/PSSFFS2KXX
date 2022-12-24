tool
extends Node2D

export (Vector2) var force = Vector2(200,0) setget set_force # kg*pix/s^2"
export (Vector2) var rectangle_extents = Vector2(256,128) setget set_extents

func set_force(f : Vector2):
	force = f
func set_extents(e : Vector2):
	rectangle_extents = e
	$Area2D/CollisionShape2D.shape.extents = rectangle_extents

func _ready():
	pass # Replace with function body.



func _on_Area2D_body_entered(body):
	if body.has_method("has_force") and body.has_method("add_force"):
		if !body.has_force(self.name):
			body.add_force(self.name, force)
	else:
		push_warning("no method add_force in "+body.name)

func _on_Area2D_body_exited(body):
	if body.has_method("has_force") and body.has_method("remove_force"):
		if body.has_force(self.name):
			body.remove_force(self.name)
	else:
		push_warning("no method add_force in "+body.name)
