extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_R:
			reload_level()

func reload_level():
	get_tree().reload_current_scene()
