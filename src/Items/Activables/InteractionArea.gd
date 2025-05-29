# A generic interaction area that can be child of any 2D node.
@tool
@icon("res://assets/art/icons/warning.png")
extends Area2D
class_name InteractionArea

signal handler_entered
signal handler_exited
signal handler_interacted(handler : InteractionHandler)

@export var enabled : bool = true ## WARNING useless for now
var enter: Callable = func():
	handler_entered.emit()
var exit: Callable = func():
	handler_exited.emit()
var interact: Callable = func (handler):
	# print_debug(name+" interact!")
	handler_interacted.emit(handler)
	
func _init():
	monitoring = false
	collision_layer = 2048 # interaction layer
	collision_mask = 0 
	#modulate = Color(0.176, 0.922, 0.51, 0.804)
