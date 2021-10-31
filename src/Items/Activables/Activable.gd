extends Node2D
class_name Activable

export (bool) var activated = false setget set_activated, is_activated

func _ready():
	add_to_group("activables")

func enable():
	print("enable")
	activated = true
	on_enable()
func on_enable():
	pass

func disable():
	print("disable")
	activated = false
	on_disable()
func on_disable():
	pass

func set_activated(b):
	if b :
		enable()
	else :
		disable()

func is_activated():
	return activated

func toggle():
	set_activated(!activated)
