extends Node2D
class_name Activable
# @icon("res://assets/art/icons/activable.png")

signal is_enabled
signal is_disabled
signal is_toggled(b)

@export var activated : bool = false : get = is_activated, set = set_activated
@export var locked : bool = false

func _init():
	add_to_group("activables")

func lock():
	locked = true

func unlock():
	locked = false

func enable():
	set_activated(true)
func on_enable():
	pass

func disable():
	set_activated(false)
func on_disable():
	pass

func set_activated(b):# be careful, in Godot4 we can have infinite recursion
	if b :
		if not locked:
			print("enable: " + str(self.name))
			var temp = activated
			activated = true
			on_enable()
			is_enabled.emit()
			if !temp:
				is_toggled.emit(activated)
	else :
		if not locked:
			print("disable: " + str(self.name))
			var temp = activated
			activated = false
			on_disable()
			is_disabled.emit()
			if temp:
				is_toggled.emit(activated)

func set_not_activated(b):
	set_activated(not b)

func is_activated():
	return activated

func toggle():
	set_activated(!activated)

func toggle_activated(b):
	set_activated(!activated)
