@icon("res://assets/art/icons/change-user-r-16.png")
extends Area2D
class_name BelongHandler
## handle how a character can belong to another node
# The call are as follows:
# 	- the holder wants to pickup the character and call belonghandler.get_in(holder)
# 	- get_in(holder) check if the holder is able to pickup the character.
# 		If yes, it returns true and update the current_holder and
#		call holder._get_in(character), which will emit a signal
# 	- Then belonghandler call holder._process_character(character, delta) and
# 		holder._physics_process_character(character, delta) each frames,
#		which will emit a signal each time
# 	- To get out, call belonghandler.get_out(), it will call
# 		holder._get_out(character), which will emit a signal

signal holder_changed(new_holder)

@export var character : Node2D = null ## the character associated to this belonghandler

@export var can_belong : bool = true ## if the character can belong
@export var can_process : bool = true : set = set_can_process ## if the belong_process is called each process frame
@export var can_physics_process : bool = true : set = set_can_physics_process ## if the belong_physics_process is called each physics_process frame
var current_holder : CharacterHolder = null : set = set_current_holder ## the current holder of the character

func set_can_process(b : bool):
	can_process = b
	set_process(b)

func set_can_physics_process(b : bool):
	can_physics_process = b
	set_physics_process(b)

func _process(delta):
	process_character(delta)

func _physics_process(delta):
	physics_process_character(delta)

func is_belonging() -> bool:
	return current_holder != null
func belongs_to(holder : CharacterHolder) -> bool:
	return current_holder == holder

func set_current_holder(holder : CharacterHolder) -> void:
	current_holder = holder
	holder_changed.emit(current_holder)

################################################################################

## Return if the character got in the holder
func get_in(new_holder : CharacterHolder)-> bool:
	if not new_holder is CharacterHolder:
		printerr("new_holder ("+new_holder.name+") is not CharacterHolder.")
		return false
	if not new_holder.can_hold:
		push_warning(" - "+new_holder.name+".can_hold is false")
		return false
	if not self.can_belong:
		push_warning(" - "+self.name+".can_belong is false")
		return false
	if is_belonging():
		# check priority, with priority to current_holder if equal:
		if new_holder.get_holder_priority() <= current_holder.get_holder_priority():
			return false
		get_out()
	current_holder = new_holder
	current_holder._get_in(self)
	return true

func get_out() -> void:
	if is_belonging():
		current_holder._get_out(self)
		current_holder = null

func process_character(delta : float):
	if is_belonging():
		current_holder._process_character(self, delta)

func physics_process_character(delta : float):
	if is_belonging():
		current_holder._physics_process_character(self, delta)
