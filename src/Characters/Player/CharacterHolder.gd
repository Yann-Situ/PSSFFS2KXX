extends Node2D
class_name CharacterHolder
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

signal processing_character(belong_handler, delta)
signal physics_processing_character(belong_handler, delta)
signal getting_in(belong_handler)
signal getting_out(belong_handler)

enum HOLDER_TYPE {NO_TYPE, GRIND, HANG, FOLLOW, ROLL}

@export var can_hold : bool = true ## if the holder can hold
@export var holder_type : HOLDER_TYPE = HOLDER_TYPE.NO_TYPE ## type for the character actions to trigger
@export var holder_priority : int = 0 : get = get_holder_priority ## priority between holders
var belong_handlers : Array[BelongHandler] = [] ## it could be a dictionary but in practice 
# there are only few belong_handlers on board

func get_holder_priority()-> int:
	return holder_priority

## if null or no arguments, then return true iff it's not holding any belong_handler
## else, return if belong_handler is in belong_handlers
func is_holding(belong_handler : BelongHandler = null) -> bool:
	if belong_handler == null:
		return belong_handlers != []
	return belong_handler in belong_handlers

func _process_character(belong_handler : BelongHandler, delta : float) -> void:
	processing_character.emit(belong_handler, delta)
func _physics_process_character(belong_handler : BelongHandler, delta : float) -> void:
	physics_processing_character.emit(belong_handler, delta)

func _get_in(belong_handler : BelongHandler) -> void:
	if is_holding(belong_handler):
		printerr("belong_handler already in belong_handlers")
		return
	belong_handlers.append(belong_handler)
	getting_in.emit(belong_handler)
	
func _get_out(belong_handler : BelongHandler) -> void:
	if !is_holding(belong_handler):
		printerr("belong_handler not in belong_handlers")
		return
	belong_handlers.erase(belong_handler)
	getting_out.emit(belong_handler)
