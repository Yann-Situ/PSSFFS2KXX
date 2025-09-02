@icon("res://assets/art/icons/fullspeed-16.png")
extends Node
class_name FullSpeedHandler

signal begin_fullspeed
signal end_fullspeed

@export var ghost_handler : GhostHandler
#@export var combo_element : ComboElement

var activated : bool = false : get = is_activated, set = set_activated
func is_activated() -> bool:
	return activated
func set_activated(b : bool):
	activated = b

var locked : bool = false : get = is_locked, set = set_locked
func is_locked() -> bool:
	return locked
func set_locked(b : bool):
	locked = b

func _ready() -> void:
	assert(ghost_handler != null)

func start():
	if is_activated():
		#push_warning(self.name+".start() but is already activated")
		return
	if is_locked():
		#push_warning(self.name+".start() but is locked")
		return
	set_activated(true)
	begin_fullspeed.emit()
	print(" - FULLSPEED begin")
	if !ghost_handler.is_running():
		ghost_handler.start(-1, 0.1)
func stop():
	if !is_activated():
		#push_warning(self.name+".stop() but is not activated")
		return
	if is_locked():
		#push_warning(self.name+".stop() but is locked")
		return
	end_fullspeed.emit()
	set_activated(false)
	print(" - FULLSPEED end")
	if ghost_handler.is_running():
		ghost_handler.stop()
