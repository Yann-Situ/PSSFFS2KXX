extends Node2D
class_name Room

signal exit_room
signal finish_room

onready var TransitionHandler = get_node("TransitionHandler")

func exit_room(next_room : NodePath):
	emit_signal("exit_room", next_room)
	get_tree().change_scene(next_room)
	get_tree().reload_current_scene()
