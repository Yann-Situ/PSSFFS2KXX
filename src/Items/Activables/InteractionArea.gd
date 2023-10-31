# A generic interaction area that can be child of any 2D node.
extends Area2D
class_name InteractionArea
# @icon("res://assets/art/icons/interaction.png")

@export var enter: Callable = func():
	pass
@export var exit: Callable = func():
	pass
@export var interact: Callable = func():
	print(name+" interact!")
	pass
