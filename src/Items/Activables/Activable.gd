extends Node2D
class_name Activable, "res://assets/art/icons/activable.png"

export (bool) var activated = false setget set_activated, is_activated

func _init():
	add_to_group("activables")

func enable():
	print("enable: " + str(self.name))
	activated = true
	on_enable()
func on_enable():
	pass

func disable():
	print("disable: " + str(self.name))
	activated = false
	on_disable()
func on_disable():
	pass

func set_activated(b):
	if b :
		enable()
	else :
		disable()

func set_not_activated(b):
	if b :
		disable()
	else :
		enable()

func is_activated():
	return activated

func toggle():
	set_activated(!activated)

func toggle_activated(b):
	set_activated(!activated)
