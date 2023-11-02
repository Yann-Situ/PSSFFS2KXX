# A generic interaction area that can be child of any 2D node.
@icon("res://assets/art/icons/warning.png")
extends Area2D
class_name InteractionArea

@export var enter: Callable = func():
	pass
@export var exit: Callable = func():
	pass
@export var interact: Callable = func():
	print(name+" interact!")
	pass
