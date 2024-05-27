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

signal processing_character(character, delta)
signal physics_processing_character(character, delta)
signal getting_in(character)
signal getting_out(character)

enum HOLDER_TYPE {NO_TPYE, GRIND, HANG, FOLLOW, ROLL}

@export var can_hold : bool = true ## if the holder can hold
@export var holder_type : HOLDER_TYPE = HOLDER_TYPE.NO_TPYE ## type for the character actions to trigger
@export var holder_priority : int = 0 : get = get_holder_priority ## priority between holders
var characters : Array[Node2D] = [] ## it could be a dictionary but in practice 
# there are only few characters on board

func get_holder_priority()-> int:
	return holder_priority

## if null or no arguments, then return true iff it's not holding any charac
## else, return if charac is in chracters
func is_holding(character : Node2D = null) -> bool:
	if character == null:
		return characters != []
	return character in characters

func _process_character(character : Node2D, delta : float) -> void:
	processing_character.emit(character, delta)
func _physics_process_character(character : Node2D, delta : float) -> void:
	physics_processing_character.emit(character, delta)

func _get_in(character : Node2D) -> void:
	if is_holding(character):
		printerr("character already in characters")
		return
	characters.append(character)
	getting_in.emit(character)
	
func _get_out(character : Node2D) -> void:
	if !is_holding(character):
		printerr("character not in characters")
		return
	characters.erase(character)
	getting_out.emit(character)
