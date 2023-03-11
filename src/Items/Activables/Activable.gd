extends Node2D
class_name Activable, "res://assets/art/icons/activable.png"

signal is_enabled
signal is_disabled
signal is_toggled(b)

@export (bool) var activated = false : get = is_activated, set = set_activated
@export (bool) var locked = false

func _init():
	add_to_group("activables")

func lock():
	locked = true
	
func unlock():
	locked = false

func enable():
	if not locked:
		print("enable: " + str(self.name))
		var temp = activated
		activated = true
		on_enable()
		emit_signal("is_enabled")
		if !temp:
			emit_signal("is_toggled", activated)
func on_enable():
	pass

func disable():
	if not locked:
		print("disable: " + str(self.name))
		var temp = activated
		activated = false
		on_disable()
		emit_signal("is_disabled")
		if temp:
			emit_signal("is_toggled", activated)
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
