@icon("res://assets/art/icons/round-r-16.png")
extends Area2D
class_name BelongHandler
## handle how a character can belong to another node
# The call are as follows:
# 	- the holder wants to pickup the character and call belonghandler.get_in(holder)
# 	- get_in(holder) check if the holder is able to pickup the character.
# 		If yes, it returns true and update the current_holder
# 	- Then belonghandler call holder.process_character(character, delta) and
# 		holder.physics_process_character(character, delta) each frames
# 	- To get get out, call character.get_out(), it will call
# 		holder.on_get_out(character)

signal holder_changed(new_holder)

@export var character : Node2D ## the character associated to this belonghandler

@export var can_belong : bool = true ## if the character can belong
@export var can_process : bool = true : set = set_can_process ## if the belong_process is called each process frame
@export var can_physics_process : bool = true : set = set_can_physics_process ## if the belong_physics_process is called each physics_process frame
var current_holder : Node2D = null : set = set_current_holder ## the current holder of the character

func is_belonging() -> bool:
	return current_holder != null
func belongs_to(holder : Node2D) -> bool:
	return current_holder == holder

func set_current_holder(holder : Node2D) -> void:
	current_holder = holder
	holder_changed.emit(current_holder)

## Return if the character got in the holder
func get_in(new_holder : Node2D): -> bool
	if not new_holder.is_in_group("characterholders"):
		printerr("new_holder ("+new_holder.name+") is not in group `characterholders`.")
		return false
	if is_belonging():
		# check priority, with priority to the new_holder if equal:
		if new_holder.get_holder_priority() < current_holder.get_holder_priority():
			return false
		get_out()
	character_holder = new_holder
	return true

func get_out() -> void:
	if is_belonging():
		current_holder.on_get_out(character)
	current_holder = null

func process_character(delta : float):
	if is_belonging():
		current_holder.process_character(character, delta)

func physics_process_character(delta : float):
	if is_belonging():
		current_holder.physics_process_character(character, delta)

################################################################################

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
